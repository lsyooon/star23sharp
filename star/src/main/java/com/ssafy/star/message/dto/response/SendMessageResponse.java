package com.ssafy.star.message.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class SendMessageResponse {
    private Long messageId;
    private List<String> receiverNames;
    private LocalDateTime createdDate;
    private String title;
    private String content;
    private String image;
    private boolean kind;
    private short receiverType;
    private boolean state;
    private String recipient;
    @JsonIgnore
    private Long groupId;

    public SendMessageResponse(Long messageId, LocalDateTime createdDate, String title, String content, String image, boolean kind, short receiverType, boolean state, Long groupId) {
        this.messageId = messageId;
        this.createdDate = createdDate;
        this.title = title;
        this.content = content;
        this.image = image;
        this.kind = kind;
        this.receiverType = receiverType;
        this.state = state;
        this.groupId = groupId;
    }

    public void setReceiverNames(List<String> recipients) {
        this.receiverNames = recipients;
    }
    public void setRecipient(String recipient) {
        this.recipient = recipient;
    }
}
