package com.ssafy.star.message.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.time.LocalDateTime;

@Getter
@Setter
@ToString
public class SendMessageListResponseDto {
    private Long messageId;
    private String title;
    private String recipient;
    private String createdDate;
    private boolean kind;
    private boolean state;
    private short receiverType;
    @JsonIgnore
    private String receiverName;
    @JsonIgnore
    private LocalDateTime createdAt;
    @JsonIgnore
    private Long groupId;
    @JsonIgnore
    private Boolean isFound;

    public SendMessageListResponseDto(Long messageId, String title, String recipient, short receiverType, LocalDateTime createdAt, boolean kind, boolean state, Long groupId, Boolean isFound) {
        this.messageId = messageId;
        this.title = title;
        this.recipient = recipient;
        this.receiverType = receiverType;
        this.createdAt = createdAt;
        this.kind = kind;
        this.state = state;
        this.groupId = groupId;
        this.isFound = isFound;
    }

    // 쿼리에 맞춘 생성자
    public SendMessageListResponseDto(Long messageId, String title, String recipient, LocalDateTime createdAt, boolean kind, boolean state, short receiverType, Long groupId) {
        this.messageId = messageId;
        this.title = title;
        this.recipient = recipient;
        this.createdAt = createdAt;
        this.kind = kind;
        this.state = state;
        this.receiverType = receiverType;
        this.groupId = groupId;
    }

    public void setRecipient(String recipient) {
        this.recipient = recipient;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }

}
