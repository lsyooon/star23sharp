package com.ssafy.star.security.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class JoinDTO {

    private String memberId;

    private String password;

    private String nickname;
}
