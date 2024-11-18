package com.ssafy.star.message.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class SendMessageListResponse {
    private Long messageId;
    private String title;
    private String recipient;
    private String createdDate;
    private boolean kind;
    private boolean state;
    private short receiverType;
    @JsonIgnore
    private LocalDateTime createdAt;
    @JsonIgnore
    private Long groupId;

    public SendMessageListResponse(Long messageId, String title, short receiverType, LocalDateTime createdAt, boolean kind, boolean state, Long groupId) {
        this.messageId = messageId;
        this.title = title;
        this.receiverType = receiverType;
        this.createdAt = createdAt;
        this.kind = kind;
        this.state = state;
        this.groupId = groupId;
    }
    public void setRecipient(String recipient) {
        this.recipient = recipient;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }

}