package com.ssafy.star.member.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.dto.request.DeviceTokenRequest;
import com.ssafy.star.member.dto.response.NotificationListResponse;
import com.ssafy.star.member.dto.response.NotificationResponse;
import com.ssafy.star.member.entity.DeviceToken;
import com.ssafy.star.member.repository.DeviceTokenRepository;
import com.ssafy.star.member.repository.MemberRepository;
import com.ssafy.star.member.entity.Notification;
import com.ssafy.star.member.repository.NotificationRepository;
import com.ssafy.star.message.entity.Message;
import com.ssafy.star.message.repository.MessageRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class NotificationService {

    private final DeviceTokenRepository deviceTokenRepository;
    private final MemberRepository memberRepository;
    private final MessageRepository messageRepository;
    private final NotificationRepository notificationRepository;
    private final AddressService addressService;
    private final PushNotificationService pushNotificationService;

    public NotificationService(DeviceTokenRepository deviceTokenRepository, MemberRepository memberRepository, MessageRepository messageRepository, NotificationRepository notificationRepository, AddressService addressService, PushNotificationService pushNotificationService) {
        this.deviceTokenRepository = deviceTokenRepository;
        this.memberRepository = memberRepository;
        this.messageRepository = messageRepository;
        this.notificationRepository = notificationRepository;
        this.addressService = addressService;
        this.pushNotificationService = pushNotificationService;
    }

    public void saveFcmToken(Long userId, DeviceTokenRequest deviceToken) {
        if (deviceToken == null) {
            throw new CustomException(CustomErrorCode.INVALID_DEVICE_TOKEN);
        }

        String userName = memberRepository.findMemberNameById(userId);
        // redis에 회원 존재하는지 확인
        DeviceToken existingToken = deviceTokenRepository.findById(userName).orElse(null);

        if (existingToken != null) {
            // 존재하면 토큰 업데이트
            existingToken.setDeviceToken(deviceToken.getToken());
            existingToken.setActive(true); // 업데이트 시 활성화 상태로 설정
            deviceTokenRepository.save(existingToken);
        } else {
            // 존재하지 않으면 새로 생성 후 저장
            DeviceToken newToken = new DeviceToken(userName, deviceToken.getToken());
            deviceTokenRepository.save(newToken);
        }
        memberRepository.updatePushNotificationEnabledById(userId, true);
    }

    // 푸시 알림 on/off 설정
    public void toggleNotification(Long userId) {
        String userName = memberRepository.findMemberNameById(userId);
        DeviceToken deviceToken = deviceTokenRepository.findById(userName)
                .orElseThrow(() -> new CustomException(CustomErrorCode.DEVICE_TOKEN_NOT_FOUND));

        boolean newActiveStatus = !deviceToken.isActive();
        deviceToken.setActive(newActiveStatus);
        deviceTokenRepository.save(deviceToken);
        memberRepository.updatePushNotificationEnabledById(userId, newActiveStatus);
    }

    // 로그아웃 시 푸시 알림 off 설정
    public void offNotification(Long userId) {
        String userName = memberRepository.findMemberNameById(userId);
        DeviceToken deviceToken = deviceTokenRepository.findById(userName)
                .orElseThrow(() -> new CustomException(CustomErrorCode.DEVICE_TOKEN_NOT_FOUND));
        deviceToken.setActive(false);
        deviceTokenRepository.save(deviceToken);
        memberRepository.updatePushNotificationEnabledById(userId, false);
    }

    // 수신인이 읽었을 경우 발신인한테 알림 전송
    public void readReceiver(Long messageId, Long receiverId) {
        Long senderId = messageRepository.findSenderIdByMessageId(messageId);
        String senderNickname = memberRepository.findNicknameById(senderId);
        String receiverNickname = memberRepository.findNicknameById(receiverId);
        Notification notification = new Notification();
        notification.setTitle("\uD83D\uDC8C " + receiverNickname+ "님이 " + senderNickname + "님의 쪽지를 확인했어요! \uD83C\uDF89");
        notification.setContent(senderNickname + "님이 숨겨둔 쪽지를 누군가 발견하고 확인했어요! \uD83D\uDE0A 또 다른 장소에 쪽지를 남겨 더 많은 사람들에게 기쁨을 전해보는 건 어떨까요? \uD83C\uDF3C");
        notification.setMessage(messageRepository.findMessageById(messageId));
        notification.setMember(memberRepository.findMemberById(senderId));
        notificationRepository.save(notification);

        String senderName = memberRepository.findMemberNameById(senderId);
        // 레디스에서 토큰 조회 -> 푸시알림 전송
        DeviceToken senderToken = deviceTokenRepository.findById(senderName).orElse(null);
        if (senderToken != null && senderToken.isActive()) {
            pushNotificationService.sendPushNotification(senderToken.getDeviceToken(), "" + notification.getId(), notification.getTitle(), notification.getContent());
        }
    }

    // 수신인에게 보물 쪽지가 왔을 경우
    public void receiveMessage(Long senderId, Long receiverId, Long messageId) {
        String receiverNickname = memberRepository.findNicknameById(receiverId);
        String senderNickname = memberRepository.findNicknameById(senderId);
        Message message = messageRepository.findMessageById(messageId);

        // 위경도 주소로 변환
        double latitude = (double) message.getLat();
        double longitude = (double) message.getLng();
        String address = addressService.getAddressFromCoordinates(latitude, longitude);

        Notification notification = new Notification();
        notification.setTitle("새로운 쪽지가 도착했어요! \uD83D\uDCEC");
        String content = senderNickname + "님이 " + receiverNickname + "님에게 살짝 보물 쪽지를 남겼어요! \uD83D\uDC8C 힌트를 보고 쪽지를 찾아보세요\uD83D\uDE04\n위치 : " + address;
        notification.setContent(content);
        notification.setMember(memberRepository.findMemberById(receiverId));
        notification.setMessage(messageRepository.findMessageById(messageId));
        notification.setImage(message.getDotHintImage());
        notification.setHint("힌트 : " + message.getHint());
        notificationRepository.save(notification);

        String receiverName = memberRepository.findMemberNameById(receiverId);
        System.out.println(notification.getId());
        // 레디스에서 토큰 조회 -> 푸시알림 전송
        DeviceToken receiverToken = deviceTokenRepository.findById(receiverName).orElse(null);
        if (receiverToken != null && receiverToken.isActive()) {
            pushNotificationService.sendPushNotification(receiverToken.getDeviceToken(), notification.getTitle(), notification.getContent(), "" + notification.getId(), notification.getHint(), message.getDotHintImage());
        }
    }

    // 수신인에게 일반 쪽지가 왔을 경우
    public void receiveCommonMessage(Long senderId, Long receiverId, Long messageId) {
        String senderNickname = memberRepository.findNicknameById(senderId);
        Notification notification = new Notification();
        notification.setTitle("새로운 쪽지가 도착했어요! \uD83D\uDCEC");
        notification.setContent(senderNickname + "님에게서 쪽지가 도착했어요 \uD83D\uDE0A 답장을 보내주세요 \uD83C\uDF3C");
        notification.setMessage(messageRepository.findMessageById(messageId));
        notification.setMember(memberRepository.findMemberById(senderId));
        notificationRepository.save(notification);

        String receiverName = memberRepository.findMemberNameById(receiverId);
        // 레디스에서 토큰 조회 -> 푸시알림 전송
        DeviceToken receiverToken = deviceTokenRepository.findById(receiverName).orElse(null);
        if (receiverToken != null && receiverToken.isActive()) {
            pushNotificationService.sendPushNotification(receiverToken.getDeviceToken(), "" + notification.getId(), notification.getTitle(), notification.getContent());
        }
    }


    // 알림 리스트
    public List<NotificationListResponse> getNotificationList(Long userId) {
        List<NotificationListResponse> notificationList = notificationRepository.getNotificationListByMemberId(userId);

        // 리스트가 null일 경우 빈 리스트로 초기화
        if (notificationList == null) {
            notificationList = new ArrayList<>();
        }

        LocalDateTime now = LocalDateTime.now();
        for (NotificationListResponse notificationListResponse : notificationList) {
            String formattedDate = formatCreatedDate(notificationListResponse.getCreatedAt(), now);
            notificationListResponse.setCreatedDate(formattedDate);
        }

        return notificationList;
    }

    // 알림 상세보기
    public NotificationResponse getNotification(Long userId, Long notificationId) {
        NotificationResponse notificationResponse = notificationRepository.getNotificationById(notificationId);
        if (notificationResponse == null) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_NOTIFICATION);
        }
        if (!notificationRepository.existsByMemberIdAndId(userId, notificationId)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_NOTIFICATION_ACCESS);
        }
        LocalDateTime now = LocalDateTime.now();
        String formattedDate = formatCreatedDate(notificationResponse.getCreatedAt(), now);
        notificationResponse.setCreatedDate(formattedDate);
        // 알림 확인여부 true로 업데이트
        notificationRepository.updateIsReadById(notificationId);
        return notificationResponse;
    }

    /* 중복 메서드 */
    // 날짜 포맷 메서드
    private String formatCreatedDate(LocalDateTime createdAt, LocalDateTime now) {
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        return createdAt.toLocalDate().isEqual(now.toLocalDate())
                ? createdAt.format(timeFormatter) // 오늘 날짜면 시간만
                : createdAt.format(dateFormatter); // 오늘 이전 날짜면 날짜만
    }

}
