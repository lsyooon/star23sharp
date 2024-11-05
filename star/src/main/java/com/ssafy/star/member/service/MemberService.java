package com.ssafy.star.member.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.dto.request.DeviceTokenRequest;
import com.ssafy.star.member.entity.DeviceToken;
import com.ssafy.star.member.repository.DeviceTokenRepository;
import com.ssafy.star.member.repository.MemberRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly=true)
public class MemberService {

    private final DeviceTokenRepository deviceTokenRepository;
    private final MemberRepository memberRepository;

    public MemberService(DeviceTokenRepository deviceTokenRepository, MemberRepository memberRepository) {
        this.deviceTokenRepository = deviceTokenRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional
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
    @Transactional
    public void toggleNotification(Long userId) {
        String userName = memberRepository.findMemberNameById(userId);
        DeviceToken deviceToken = deviceTokenRepository.findById(userName)
                .orElseThrow(() -> new CustomException(CustomErrorCode.DEVICE_TOKEN_NOT_FOUND));

        boolean newActiveStatus = !deviceToken.isActive();
        deviceToken.setActive(newActiveStatus);
        deviceTokenRepository.save(deviceToken);
        memberRepository.updatePushNotificationEnabledById(userId, newActiveStatus);
    }
}
