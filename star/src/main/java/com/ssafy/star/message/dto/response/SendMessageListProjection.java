package com.ssafy.star.message.dto.response;

import java.time.LocalDateTime;

public interface SendMessageListProjection {
    Long getMessageId();
    String getTitle();
    String getRecipient();
    LocalDateTime getCreatedAt();
    boolean isKind();
    short getReceiverType();
    Long getGroupId();
    Boolean getIsFound();
}
