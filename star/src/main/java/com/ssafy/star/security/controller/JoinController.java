package com.ssafy.star.security.controller;


import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.JoinDTO;
import com.ssafy.star.security.service.JoinService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1")
public class JoinController {


    private final JoinService joinService;

    @PostMapping("/join")
    public ResponseEntity<?> join(@RequestBody JoinDTO joinDTO) {

        joinService.joinProcess(joinDTO);

        return ResponseEntity.ok().body(new ApiResponse<>("200","회원가입 성공"));
    }

    @GetMapping("/check-nickname")
    public ResponseEntity<?> checkNickname(@RequestParam("nickname") String nickname) {
        joinService.checkNickname(nickname);
        return ResponseEntity.ok().body(new ApiResponse<>("200","사용 가능한 닉네임입니다."));
    }

    @GetMapping("/check-memberId")
    public ResponseEntity<?> checkId(@RequestParam("memberId") String memberId) {
        joinService.checkMemberId(memberId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "사용 가능한 아이디입니다."));
    }



}
