package com.ssafy.star.message.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class SendMessageListResponse {
    private Long messageId;
    private String title;
    private String recipient;
    private LocalDateTime createdAt;
    private String createdDate;
    private boolean kind;
    private int state;
}
