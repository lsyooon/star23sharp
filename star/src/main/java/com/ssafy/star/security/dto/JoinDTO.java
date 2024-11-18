package com.ssafy.star.security.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class JoinDTO {


    @NotBlank(message = "아이디는 필수 입력 값입니다.")
    @Pattern(regexp = "^[a-z0-9]{3,16}$", message = "아이디는 영문 소문자와 숫자 3~16자리여야 합니다.")
    private String memberId;
    @NotBlank(message = "비밀번호는 필수 입력 값입니다.")
    @Pattern(regexp = "^(?=.*[0-9])(?=.*[a-zA-Z])[a-zA-Z0-9!@#$%^&*()._-]{6,16}$", message = "비밀번호는 6자 이상 16자 이하이며, 영어와 숫자의 조합이어야 하고, . _ - 및 특수문자도 허용됩니다.")
    private String password;
    @NotBlank(message = "닉네임은 필수 입력 값입니다.")
    @Pattern(regexp = "^[a-z0-9가-힣]{2,16}$", message = "닉네임은 2자 이상 16자 이하, 영어, 숫자 또는 한글로 구성되어야 합니다. 초성과 모음만 사용은 불가합니다.")
    private String nickname;

}
