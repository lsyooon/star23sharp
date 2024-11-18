package com.ssafy.star.member.dto.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
public class NotificationResponse {
    private Long notificationId;
    private String title;
    private String content;
    private String hint;
    private String image;
    private String createdDate;
    @JsonIgnore
    private LocalDateTime createdAt;

    public NotificationResponse(Long notificationId, String title, String content, String hint, String image, LocalDateTime createdAt) {
        this.notificationId = notificationId;
        this.title = title;
        this.content = content;
        this.hint = hint;
        this.image = image;
        this.createdAt = createdAt;
    }

    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }

}
