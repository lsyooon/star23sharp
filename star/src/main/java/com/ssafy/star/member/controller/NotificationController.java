package com.ssafy.star.member.controller;

import com.ssafy.star.member.dto.request.DeviceTokenRequest;
import com.ssafy.star.member.dto.request.ReceiverPushRequest;
import com.ssafy.star.member.dto.request.SenderPushRequest;
import com.ssafy.star.member.dto.response.NotificationListResponse;
import com.ssafy.star.member.dto.response.NotificationResponse;
import com.ssafy.star.member.service.NotificationService;
import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.CustomUserDetails;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notification")
public class NotificationController {
    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @PostMapping("/device")
    public ResponseEntity<ApiResponse<?>> saveDeviceToken(@AuthenticationPrincipal CustomUserDetails user,
                                                          @RequestBody DeviceTokenRequest token) {
        notificationService.saveFcmToken(user.getId(), token);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "디바이스 토큰 저장 완료"));
    }

    @PostMapping("/push-toggle")
    public ResponseEntity<ApiResponse<?>> toggleNotification(@AuthenticationPrincipal CustomUserDetails user) {
        notificationService.toggleNotification(user.getId());
        return ResponseEntity.ok().body(new ApiResponse<>("200", "알림 설정 변경 완료"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationListResponse>>> getPushList(@AuthenticationPrincipal CustomUserDetails user) {
        List<NotificationListResponse> response = notificationService.getNotificationList(user.getId());
        if (response.isEmpty()){
            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료. 받은 알림이 없습니다."));
        }
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
    }

    @GetMapping("/{notificationId}")
    public ResponseEntity<ApiResponse<NotificationResponse>> getNotification(@AuthenticationPrincipal CustomUserDetails user,
                                                                             @PathVariable Long notificationId) {
        NotificationResponse response = notificationService.getNotification(user.getId(), notificationId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
    }

    @PostMapping("/sender-push")
    public ResponseEntity<ApiResponse<?>> senderPush(@AuthenticationPrincipal CustomUserDetails user,
                                                     @RequestBody SenderPushRequest request) {
        notificationService.readReceiver(request.getMessageId(), user.getId());
        return ResponseEntity.ok().body(new ApiResponse<>("200", "알림 전송 완료"));
    }

    @PostMapping("/receiver-push")
    public ResponseEntity<ApiResponse<?>> receiverPush(@AuthenticationPrincipal CustomUserDetails user,
                                                       @RequestBody ReceiverPushRequest request) {
        notificationService.receiveMessage(user.getId(), request.getReceiverId(), request.getMessageId());
        return ResponseEntity.ok().body(new ApiResponse<>("200", "알림 전송 완료"));
    }

}
