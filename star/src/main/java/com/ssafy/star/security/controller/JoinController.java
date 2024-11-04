package com.ssafy.star.security.controller;


import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.DuplicateDto;
import com.ssafy.star.security.dto.JoinDTO;
import com.ssafy.star.security.service.JoinService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/v1/member")
public class JoinController {


    private final JoinService joinService;

    @PostMapping("/join")
    public ResponseEntity<?> join(@RequestBody JoinDTO joinDTO) {

        joinService.joinProcess(joinDTO);

        return ResponseEntity.ok().body(new ApiResponse<>("200","회원가입 성공"));
    }

    @PostMapping("/duplicate")
    public ResponseEntity<?> checkNickname(@RequestBody DuplicateDto req) {
        if(req.getCheckType() == 0){
            joinService.checkMemberId(req.getValue());
            return ResponseEntity.ok().body(new ApiResponse<>("200", "사용 가능한 아이디입니다."));
        }
        joinService.checkNickname(req.getValue());
        return ResponseEntity.ok().body(new ApiResponse<>("200","사용 가능한 닉네임입니다."));
    }



}
