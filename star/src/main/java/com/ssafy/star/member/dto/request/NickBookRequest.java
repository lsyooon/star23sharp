package com.ssafy.star.member.dto.request;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class NickBookRequest {

    @NotBlank(message = "저장할 닉네임을 입력하세요.")
    @Pattern(regexp = "^[a-z0-9가-힣]{2,16}$", message = "닉네임은 2자 이상 16자 이하, 영어, 숫자 또는 한글로 구성되어야 합니다. 초성과 모음만 사용은 불가합니다.")
    private String nickname;
    @Pattern(regexp = "^[가-힣]{2,10}$", message = "이름은 2자 이상 8자 이하 한글로 구성되어야 합니다. 초성과 모음만 사용은 불가합니다.")
    private String name;
    
}
