package com.ssafy.star.message.controller;

import com.ssafy.star.message.dto.response.ReceiveMessage;
import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.dto.response.SendMessage;
import com.ssafy.star.message.dto.response.SendMessageListResponse;
import com.ssafy.star.message.service.MessageService;
import org.springframework.http.ResponseEntity;
import com.ssafy.star.response.ApiResponse;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/message")
public class MessageController {
    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    @GetMapping("/reception/list")
    public ResponseEntity<ApiResponse<List<ReceiveMessageListResponse>>> getReceptionList(){
        Long userId = 1L;
        List<ReceiveMessageListResponse> response = messageService.getReceiveMessageList(userId);
        if (response.isEmpty()){
            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공. 받은 편지가 없습니다."));
        }
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공", response));
    }

    @GetMapping("/send/list")
    public ResponseEntity<ApiResponse<List<SendMessageListResponse>>> getSendMessageList(){
        Long userId = 2L;
        List<SendMessageListResponse> response = messageService.getSendMessageList(userId);
        if (response.isEmpty()){
            return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공. 보낸 편지가 없습니다."));
        }
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공", response));
    }

    @GetMapping("/reception/{messageId}")
    public ResponseEntity<ApiResponse<ReceiveMessage>> getReceptionMessage(@PathVariable Long messageId){
        Long userId = 1L;
        ReceiveMessage response = messageService.getReceiveMessage(userId, messageId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공", response));
    }

    @GetMapping("/send/{messageId}")
    public ResponseEntity<ApiResponse<SendMessage>> getSendMessage(@PathVariable Long messageId){
        Long userId = 2L;
        SendMessage response = messageService.getSendMessage(userId, messageId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "조회 성공", response));
    }

    @DeleteMapping("/{messageId}")
    public ResponseEntity<ApiResponse<?>> deleteMessage(@PathVariable Long messageId){
        Long userId = 1L;
        messageService.removeMessage(userId, messageId);
        return ResponseEntity.ok().body(new ApiResponse<>("200", "메시지가 삭제되었습니다."));
    }
}
