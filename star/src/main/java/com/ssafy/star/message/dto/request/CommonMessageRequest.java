package com.ssafy.star.message.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@NoArgsConstructor
public class CommonMessageRequest {
    private short receiverType;
    private String title;
    private String content;
    private List<String> receivers;
    private LocalDateTime createdAt;
    private MultipartFile contentImage;
    private Long groupId;
}
