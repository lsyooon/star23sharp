package com.ssafy.star.member.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class NotificationListResponse {
    private Long notificationId;
    private String title;
    private boolean isRead;
    private String createdDate;
    @JsonIgnore
    private LocalDateTime createdAt;

    public NotificationListResponse(Long notificationId, String title, LocalDateTime createdAt, boolean isRead) {
        this.notificationId = notificationId;
        this.title = title;
        this.createdAt = createdAt;
        this.isRead = isRead;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }
}
