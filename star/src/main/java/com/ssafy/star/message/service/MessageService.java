package com.ssafy.star.message.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.repository.MemberGroupRepository;
import com.ssafy.star.member.repository.MemberRepository;
import com.ssafy.star.message.dto.request.ComplaintMessageRequest;
import com.ssafy.star.message.dto.response.ReceiveMessage;
import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.dto.response.SendMessage;
import com.ssafy.star.message.dto.response.SendMessageListResponse;
import com.ssafy.star.message.entity.Complaint;
import com.ssafy.star.message.entity.ComplaintReason;
import com.ssafy.star.message.repository.ComplaintReasonRepository;
import com.ssafy.star.message.repository.ComplaintRepository;
import com.ssafy.star.message.repository.MessageBoxRepository;
import com.ssafy.star.message.repository.MessageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class MessageService {
    private final MessageRepository messageRepository;
    private final MessageBoxRepository messageBoxRepository;
    private final MemberGroupRepository memberGroupRepository;
    private final MemberRepository memberRepository;
    private final ComplaintRepository complaintRepository;
    private final ComplaintReasonRepository complaintReasonRepository;

    public MessageService(MessageRepository messageRepository, MessageBoxRepository messageBoxRepository, MemberGroupRepository memberGroupRepository, ComplaintRepository complaintRepository, MemberRepository memberRepository, ComplaintReasonRepository complaintReasonRepository) {
        this.messageRepository = messageRepository;
        this.messageBoxRepository = messageBoxRepository;
        this.memberGroupRepository = memberGroupRepository;
        this.complaintReasonRepository = complaintReasonRepository;
        this.memberRepository = memberRepository;
        this.complaintRepository = complaintRepository;
    }

    // 수신 쪽지 리스트
    public List<ReceiveMessageListResponse> getReceiveMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 1);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<ReceiveMessageListResponse> list = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<ReceiveMessageListResponse> messages = messageRepository.findReceiveMessageListByMessageIdAndMemberId(messageId, userId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

            for (ReceiveMessageListResponse message : messages) {
                String formattedDate = formatCreatedDate(message.getCreatedAt(), now);
                message.setCreatedDate(formattedDate);
            }
            list.addAll(messages);
        }

        // 날짜 기준 재정렬
        list.sort((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()));

        return list;
    }

    // 송신 쪽지 리스트
    public List<SendMessageListResponse> getSendMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 0);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<SendMessageListResponse> list = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<SendMessageListResponse> messages = messageRepository.findSendMessageListByMessageIdAndMemberId(messageId, userId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

            for (SendMessageListResponse message : messages) {
                String formattedDate = formatCreatedDate(message.getCreatedAt(), now);
                message.setCreatedDate(formattedDate);

                if (message.getReceiverType() == (short) 0) {   // 한명 전송
                    message.setRecipient(messageBoxRepository.getRecipientNameByMessageId(message.getMessageId(), (short) 1));
                } else if (message.getReceiverType() == (short) 1) {    // 단체 or 그룹 전송
                    // 단체 전송
                    String recipient = messageBoxRepository.findMemberNicknameByMessageId(message.getMessageId(), (short) 1) + " 외 "
                            + (messageBoxRepository.getMemberCountByMessageId(message.getMessageId(), (short) 1) - 1) + "명";
                    // 그룹 전송
                    if (message.getGroupId() != null) {
                        Boolean isConstructed = memberGroupRepository.findIsConstructedByGroupId(message.getGroupId());
                        // 내가 만든 그룹인지 확인
                        if (isConstructed != null && isConstructed) {
                            recipient = memberGroupRepository.findGroupNameById(message.getGroupId());
                        }
                    }
                    message.setRecipient(recipient);
                } else {    // 불특정 다수
                    message.setRecipient("모두에게");
                }
            }
            list.addAll(messages);
        }

        // 날짜 기준 재정렬
        list.sort((m1, m2) -> m2.getCreatedAt().compareTo(m1.getCreatedAt()));

        return list;
    }


    // 수신 쪽지 상세조회
    public ReceiveMessage getReceiveMessage(Long userId, Long messageId) {
        // 쪽지가 존재하는지 확인 & 리스트에서 삭제한 쪽지인지 확인
        if (!messageRepository.existsById(messageId) || messageBoxRepository.existsByMessageIdAndMemberIdAndIsDeletedFalse(messageId, userId)) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        // userId가 받은 쪽지 맞는지 확인
        if (!messageBoxRepository.existsByMemberIdAndMessageIdAndMessageDirection(userId, messageId, (short) 1)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }

        LocalDateTime now = LocalDateTime.now();
        ReceiveMessage receiveMessage = messageRepository.findReceiveMessageById(messageId, userId);
        String formattedDate = formatCreatedDate(receiveMessage.getCreatedAt(), now);
        receiveMessage.setCreatedDate(formattedDate);

        return receiveMessage;
    }

    // 송신 쪽지 상세조회
    public SendMessage getSendMessage(Long userId, Long messageId) {
        if (!messageRepository.existsById(messageId) || messageBoxRepository.existsByMessageIdAndMemberIdAndIsDeletedFalse(messageId, userId)) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        if (!messageBoxRepository.existsByMemberIdAndMessageIdAndMessageDirection(userId, messageId, (short) 0)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }

        LocalDateTime now = LocalDateTime.now();
        SendMessage sendMessage = messageRepository.findSendMessageById(messageId);
        String formattedDate = formatCreatedDate(sendMessage.getCreatedAt(), now);
        sendMessage.setCreatedDate(formattedDate);

        // 받는 사람 리스트 설정
        if (sendMessage.getReceiverType() == (short) 0) {   // 한명 전송
            // 한 명 이름을 리스트로 변환 후 설정
            sendMessage.setReceiverNames(List.of(messageBoxRepository.getRecipientNameByMessageId(sendMessage.getMessageId(), (short) 0)));
        } else if (sendMessage.getReceiverType() == (short) 1) {    // 단체 or 그룹 전송
            List<String> recipients = messageBoxRepository.getRecipientNamesByMessageId(messageId, (short) 1);
            sendMessage.setReceiverNames(recipients);

            // 그룹 전송일 경우
            if (sendMessage.getGroupId() != null) {
                Boolean isConstructed = memberGroupRepository.findIsConstructedByGroupId(sendMessage.getGroupId());

                // 내가 만든 그룹이라면 그룹 이름을 설정
                if (isConstructed != null && isConstructed) {
                    String groupName = memberGroupRepository.findGroupNameById(sendMessage.getGroupId());
                    sendMessage.setReceiverNames(List.of(groupName));
                } else {
                    // 내가 만든 그룹이 아닐 경우, 기존 recipients 리스트 설정
                    sendMessage.setReceiverNames(recipients);
                }
            } else {
                // 단체 전송일 경우 recipients 리스트 설정
                sendMessage.setReceiverNames(recipients);
            }
        } else {    // 불특정 다수
            sendMessage.setReceiverNames(List.of("모두에게"));
            if (sendMessage.isKind()) { // 보물 쪽지의 경우
                if (sendMessage.isState()) {   // 누군가 쪽지를 열었을 경우
                    sendMessage.setReceiverNames(List.of(messageBoxRepository.getRecipientNameByMessageIdAndState(sendMessage.getMessageId(), (short) 1, true)));
                }
            }
        }
        return sendMessage;
    }

    // 내 쪽지함에서 쪽지 삭제
    @Transactional
    public void removeMessage(Long userId, Long messageId) {
        if (!messageRepository.existsById(messageId)) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        if (!messageBoxRepository.existsByMemberIdAndMessageId(userId, messageId)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }
        messageBoxRepository.updateIsDeletedByMessageIdAndMemberId(messageId, userId);
    }

    // 수신 쪽지 신고하기
    @Transactional
    public void complaintMessage(Long userId, ComplaintMessageRequest request) {
        if (!messageRepository.existsById(request.getMessageId())) {
            throw new CustomException(CustomErrorCode.NOT_FOUND_MESSAGE);
        }
        if (!messageBoxRepository.existsByMemberIdAndMessageId(userId, request.getMessageId())) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_MESSAGE_ACCESS);
        }
        if (messageBoxRepository.existsByMemberIdAndMessageIdAndIsReportedTrue(userId, request.getMessageId())) {
            throw new CustomException(CustomErrorCode.ALREADY_REPORTED_MESSAGE);
        }

        Complaint complaint = new Complaint();
        ComplaintReason complaintReason = complaintReasonRepository.findById(request.getComplaintType())
                .orElseThrow(() -> new CustomException(CustomErrorCode.NOT_FOUND_COMPLAINT_REASON));
        complaint.setReporter(memberRepository.findMemberById(userId));
        complaint.setReported(memberRepository.findMemberById(messageRepository.findSenderIdByMessageId(request.getMessageId())));
        complaint.setMessage(messageRepository.findMessageById(request.getMessageId()));
        complaint.setComplaintReason(complaintReason);
        try {
            complaint.setCreatedAt(request.getComplaintTime());
        } catch (DateTimeParseException e) {
            throw new CustomException(CustomErrorCode.INVALID_DATE_FORMAT);
        }

        complaintRepository.save(complaint);
        messageBoxRepository.updateIsReportedByMessageIdAndMemberId(request.getMessageId(), userId);
    }


    /* 중복 코드 */
    // 날짜 포맷 메서드
    private String formatCreatedDate(LocalDateTime createdAt, LocalDateTime now) {
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        return createdAt.toLocalDate().isEqual(now.toLocalDate())
                ? createdAt.format(timeFormatter) // 오늘 날짜면 시간만
                : createdAt.format(dateFormatter); // 오늘 이전 날짜면 날짜만
    }
}
