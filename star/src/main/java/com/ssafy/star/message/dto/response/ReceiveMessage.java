package com.ssafy.star.message.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class ReceiveMessage {
    private Long messageId;
    private List<String> senderName;
    @JsonIgnore
    private String sender;
    @JsonIgnore
    private LocalDateTime createdAt;
    private String createdDate;
    private String title;
    private String content;
    private String image;
    private boolean kind;
    private short receiverType;

    public ReceiveMessage(Long messageId, String sender, LocalDateTime createdAt, String title, String content, String image, boolean kind, short receiverType) {
        this.messageId = messageId;
        this.sender = sender;
        this.senderName = List.of(sender);
        this.createdAt = createdAt;
        this.title = title;
        this.content = content;
        this.image = image;
        this.kind = kind;
        this.receiverType = receiverType;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }

    public void setSenderName(String sender) {
        this.senderName = List.of(sender);
    }
}
