package com.ssafy.star.message.controller;

import com.ssafy.star.message.dto.request.CommonMessageRequest;
import com.ssafy.star.message.dto.request.ComplaintMessageRequest;
import com.ssafy.star.message.dto.response.*;
import com.ssafy.star.message.service.MessageService;
import com.ssafy.star.security.dto.CustomUserDetails;
import org.springframework.http.ResponseEntity;
import com.ssafy.star.response.ApiResponse;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/v1/message")
public class MessageController {
    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @GetMapping("/reception/list/{filter}")
    public ResponseEntity<?> getReceptionList(@AuthenticationPrincipal CustomUserDetails user,
                                              @PathVariable int filter){
        List<ReceiveMessageListResponse> response;
        if (filter == 0) {  // 리스트 전체
            response = messageService.getReceiveMessageListResponse(user.getId());
        } else if (filter == 1) {   // 보물 쪽지
            response = messageService.getReceiveTreasureMessageListResponse(user.getId());
        } else {    // 일반 쪽지
            response = messageService.getReceiveCommonMessageListResponse(user.getId());
        }

        if (response.isEmpty()){
            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공. 받은 편지가 없습니다."));
        }

        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공", response));
    }

    @GetMapping("/send/list/{filter}")
    public ResponseEntity<ApiResponse<List<SendMessageListResponseDto>>> getSendMessageList(@AuthenticationPrincipal CustomUserDetails user,
                                                                                            @PathVariable int filter){
        List<SendMessageListResponseDto> response;
        if (filter == 0) {  // 리스트 전체
            response = messageService.getSendMessageListResponse(user.getId());
        } else if (filter == 1) {   // 보물 쪽지
            response = messageService.getSendTreasureMessageListResponse(user.getId());
        } else {    // 일반 쪽지
            response = messageService.getSendCommonMessageListResponse(user.getId());
        }

        if (response.isEmpty()){
            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료. 보낸 쪽지가 없습니다."));
        }
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
    }

    @GetMapping("/reception/{messageId}")
    public ResponseEntity<ApiResponse<ReceiveMessageResponse>> getReceptionMessage(@AuthenticationPrincipal CustomUserDetails user,
                                                                                   @PathVariable Long messageId){
        ReceiveMessageResponse response = messageService.getReceiveMessage(user.getId(), messageId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
    }

    @GetMapping("/send/{messageId}")
    public ResponseEntity<ApiResponse<SendMessageResponse>> getSendMessage(@AuthenticationPrincipal CustomUserDetails user,
                                                                           @PathVariable Long messageId){
        SendMessageResponse response = messageService.getSendMessage(user.getId(), messageId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
    }

    @DeleteMapping("/{messageId}")
    public ResponseEntity<ApiResponse<?>> deleteMessage(@AuthenticationPrincipal CustomUserDetails user,
                                                        @PathVariable Long messageId){
        messageService.removeMessage(user.getId(), messageId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "메시지 삭제 완료"));
    }

    @PostMapping("/report")
    public ResponseEntity<ApiResponse<?>> reportMessage(@AuthenticationPrincipal CustomUserDetails user,
                                                        @RequestBody ComplaintMessageRequest request){
        messageService.complaintMessage(user.getId(), request);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "메시지 신고 완료"));
    }

    @GetMapping("/report-reason")
    public ResponseEntity<ApiResponse<List<ComplaintReasonResponse>>> getReportReason(){
        return ResponseEntity.ok().body(new ApiResponse<>("200", "신고 사유 목록 조회 완료", messageService.complaintReasons()));
    }

    @GetMapping("/unread-state")
    public ResponseEntity<ApiResponse<Boolean>> messageListState(@AuthenticationPrincipal CustomUserDetails user){
        boolean result = messageService.stateFalse(user.getId());
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", result));
    }

    @PostMapping("/common")
    public ResponseEntity<ApiResponse<?>> insertMessage(@AuthenticationPrincipal CustomUserDetails user,
                                                        @RequestPart("request") CommonMessageRequest request,
                                                        @RequestPart(value = "contentImage", required = false) MultipartFile contentImage) throws IOException {
        messageService.commonMessage(user.getId(), request, contentImage);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "전송 완료"));
    }

    /*
    *
    *  휴지통
    *
    *
    *
    * */


//    @GetMapping("/reception/list")
//    public ResponseEntity<?> getReceptionList(@AuthenticationPrincipal CustomUserDetails user){
//        List<ReceiveMessageListResponse> response = messageService.getReceiveMessageList(user.getId());
//        if (response.isEmpty()){
//            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공. 받은 편지가 없습니다."));
//        }
//
//        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공", response));
//    }


//    @GetMapping("/send/list")
//    public ResponseEntity<ApiResponse<List<SendMessageListResponse>>> getSendMessageList(@AuthenticationPrincipal CustomUserDetails user){
//        System.out.println("--------list1------------------");
//        List<SendMessageListResponse> response = messageService.getSendMessageList(user.getId());
//        if (response.isEmpty()){
//            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료. 보낸 편지가 없습니다."));
//        }
//        System.out.println("--------list1 End!!------------------");
//        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
//    }


//    @GetMapping("/send/list2")
//    public ResponseEntity<ApiResponse<List<SendMessageListResponseDto>>> getSendMessageList2(@AuthenticationPrincipal CustomUserDetails user){
//        System.out.println("--------list2------------------");
//        List<SendMessageListResponseDto> response = messageService.getSendMessageListResponseDto(user.getId());
//        System.out.println("--------list2 End!!------------------");
//        if (response.isEmpty()){
//            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료. 보낸 편지가 없습니다."));
//        }
//        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
//    }


//    @GetMapping("/send/list3")
//    public ResponseEntity<ApiResponse<List<SendMessageListResponseDto>>> getSendMessageList3(@AuthenticationPrincipal CustomUserDetails user){
//        System.out.println("--------list3------------------");
//        List<SendMessageListResponseDto> response = messageService.getSendMessageListResponse(user.getId());
//        System.out.println("--------list3 End!!------------------");
//        if (response.isEmpty()){
//            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료. 보낸 편지가 없습니다."));
//        }
//        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 완료", response));
//    }








}
