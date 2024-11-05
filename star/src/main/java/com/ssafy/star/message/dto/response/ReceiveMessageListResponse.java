package com.ssafy.star.message.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class ReceiveMessageListResponse {
    private Long messageId;
    private String title;
    private String senderNickname;
    private short receiverType;
    @JsonIgnore
    private LocalDateTime createdAt;
    private String createdDate;
    private boolean kind;
    private boolean state;

    public ReceiveMessageListResponse(Long messageId, String title, short receiverType, String senderNickname, LocalDateTime createdAt, boolean kind, boolean state) {
        this.messageId = messageId;
        this.title = title;
        this.receiverType = receiverType;
        this.senderNickname = senderNickname;
        this.createdAt = createdAt;
        this.kind = kind;
        this.state = state;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }

}




