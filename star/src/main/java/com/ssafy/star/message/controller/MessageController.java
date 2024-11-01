package com.ssafy.star.message.controller;

import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.service.MessageService;
import org.springframework.http.ResponseEntity;
import com.ssafy.star.response.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/message")
public class MessageController {
    private MessageService messageService;

    @GetMapping("/reception/list")
    public ResponseEntity<ApiResponse<ReceiveMessageListResponse>> createTravel(
}
