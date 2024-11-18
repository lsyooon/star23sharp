package com.ssafy.star.member.dto.response;


import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NickBookResponse {


    private Long id;
    private String nickname;
    private String name;
}
