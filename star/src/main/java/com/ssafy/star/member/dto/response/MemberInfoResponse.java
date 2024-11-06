package com.ssafy.star.member.dto.response;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Builder
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class MemberInfoResponse {

    private String memberId;
    private String nickname;
    private boolean isPushNotificationEnabled;
}
