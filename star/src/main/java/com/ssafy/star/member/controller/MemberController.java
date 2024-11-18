package com.ssafy.star.member.controller;


import com.ssafy.star.member.dto.response.MemberInfoResponse;
import com.ssafy.star.member.service.MemberService;
import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/info")
    public ResponseEntity<?>  getInfo(@AuthenticationPrincipal CustomUserDetails user){
        MemberInfoResponse memberInfoResponse = memberService.findMemberInfo(user.getId());
        return new ResponseEntity<>(new ApiResponse<>("200","회원 정보 조회 성공",memberInfoResponse ), HttpStatus.OK);

    }

}
