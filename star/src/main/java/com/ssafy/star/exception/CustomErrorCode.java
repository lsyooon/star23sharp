package com.ssafy.star.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum CustomErrorCode {
    MAX_UPLOAD_SIZE_EXCEEDED("E0003", "업로드 가능한 파일 크기를 초과했습니다.", HttpStatus.PAYLOAD_TOO_LARGE),
    EMPTY_REFRESH_TOKEN("M0007", "Refresh Token이 비어있습니다.",HttpStatus.BAD_REQUEST),
    EMPTY_ACCESS_TOKEN("M0008", "Access Token이 비어있습니다.",HttpStatus.BAD_REQUEST),
    EXPIRED_TOKEN("M0000","만료된 토큰입니다.",HttpStatus.BAD_REQUEST),
    INVALID_TOKEN("M0009", "유효하지 않은 토큰입니다.", HttpStatus.BAD_REQUEST),
    MEMBER_INFO_NOT_MATCH("M0004", "회원정보가 일치하지 않습니다.", HttpStatus.BAD_REQUEST),



    ;


    private final String code;
    private final String message;
    private final HttpStatus status;

}
