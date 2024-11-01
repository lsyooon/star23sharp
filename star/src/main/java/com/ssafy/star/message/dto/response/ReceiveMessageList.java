package com.ssafy.star.message.dto.response;

import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class ReceiveMessageList {
    private Long messageId;
    private String title;
    private String senderNickname;
    private String createdDate;
    private boolean kind;

    public ReceiveMessageList(Long messageId, String title, String senderNickname, LocalDateTime createdAt, boolean kind) {
        this.messageId = messageId;
        this.title = title;
        this.senderNickname = senderNickname;
        this.createdDate = createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));  // 원하는 포맷 적용
        this.kind = kind;
    }
}

