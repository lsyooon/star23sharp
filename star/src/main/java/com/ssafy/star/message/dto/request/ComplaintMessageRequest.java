package com.ssafy.star.message.dto.request;

import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class ComplaintMessageRequest {
    private Long messageId;
    private short complaintType;
    private LocalDateTime complaintTime;
}
