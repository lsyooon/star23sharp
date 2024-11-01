package com.ssafy.star.message.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
public class ReceiveMessageListResponse {
    private Long messageId;
    private String title;
    private String senderNickname;
    private LocalDateTime createdAt;
    private String createdDate;
    private boolean kind;

    public ReceiveMessageListResponse(Long messageId, String title, String senderNickname, LocalDateTime createdAt, boolean kind) {
        this.messageId = messageId;
        this.title = title;
        this.senderNickname = senderNickname;
        this.createdAt = createdAt;
        this.kind = kind;
    }
}




