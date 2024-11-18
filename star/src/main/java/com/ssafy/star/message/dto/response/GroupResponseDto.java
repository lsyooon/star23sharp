package com.ssafy.star.message.dto.response;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class GroupResponseDto {

    String groupName;
    Long groupMemberCount;
    String nickname;


    public GroupResponseDto( Long groupMemberCount, String nickname) {
        this.groupMemberCount = groupMemberCount;
        this.nickname = nickname;
    }

}
