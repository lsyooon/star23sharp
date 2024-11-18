package com.ssafy.star.member.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReceiverPushRequest {
    private Long receiverId;
    private Long messageId;
}
