package com.ssafy.star.member.controller;

import com.ssafy.star.member.dto.request.DeviceTokenRequest;
import com.ssafy.star.member.service.MemberService;
import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.CustomUserDetails;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member")
public class MemberController {
    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @PostMapping("/device")
    public ResponseEntity<ApiResponse<?>> saveDeviceToken(@AuthenticationPrincipal CustomUserDetails user,
                                                          @RequestBody DeviceTokenRequest token) {
        memberService.saveFcmToken(user.getId(), token);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "디바이스 토큰 저장 성공"));
    }

    @PostMapping("/push-toggle")
    public ResponseEntity<ApiResponse<?>> toggleNotification(@AuthenticationPrincipal CustomUserDetails user) {
        memberService.toggleNotification(user.getId());
        return ResponseEntity.ok().body(new ApiResponse<>("200", "알림 설정 변경이 완료되었습니다."));
    }
}
