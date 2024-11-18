package com.ssafy.star.member.controller;

import com.ssafy.star.member.dto.request.NickBookRequest;
import com.ssafy.star.member.dto.response.NickBookResponse;
import com.ssafy.star.member.service.NickBookService;
import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.CustomUserDetails;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/member/nick-book")
@RequiredArgsConstructor
public class NickBookController {

    private final NickBookService nickBookService;

    @GetMapping("")
    public ResponseEntity<?> getNickBookList(@AuthenticationPrincipal CustomUserDetails user){
        List<NickBookResponse> list = nickBookService.getNicknameBookList(user.getId());
        return ResponseEntity.ok(new ApiResponse("200","닉북 리스트 조회 성공",list));
    }

    @GetMapping("/{nickId}")
    public ResponseEntity<?> getNickBook(@AuthenticationPrincipal CustomUserDetails user, @PathVariable("nickId") Long nickId){
        NickBookResponse result = nickBookService.getNickBook(user.getId(),nickId);
        return ResponseEntity.ok(new ApiResponse("200","닉북 조회 성공",result));
    }



    @PostMapping("")
    public ResponseEntity<?> InsertNickBook(@AuthenticationPrincipal CustomUserDetails user, @Valid @RequestBody NickBookRequest nickBookRequest){

        NickBookResponse result = nickBookService.addNicknameToBook(user.getId(), nickBookRequest);

        return ResponseEntity.ok(new ApiResponse("200","닉북 저장 성공",result));
    }

    @PutMapping("/{nickId}")
    public ResponseEntity<?> updateNickBook(@AuthenticationPrincipal CustomUserDetails user,@Valid @RequestBody NickBookRequest nickBookRequest, @PathVariable("nickId") Long nickId){
        nickBookService.updateNicknameToBook(user.getId(),nickId,nickBookRequest);

        return ResponseEntity.ok(new ApiResponse<>("200","닉북 수정 성공",null));
    }

    @DeleteMapping("/{nickId}")
    public ResponseEntity<?> deleteNickBook(@AuthenticationPrincipal CustomUserDetails user, @PathVariable("nickId") Long nickId){
        nickBookService.deleteNickBook(user.getId(),nickId);

        return ResponseEntity.ok(new ApiResponse<>("200","닉북 삭제 성공",null));
    }

}
