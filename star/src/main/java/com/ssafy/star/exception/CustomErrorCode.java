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
    NOT_FOUND_MESSAGE("L0001", "쪽지가 존재하지 않습니다.", HttpStatus.NOT_FOUND),
    UNAUTHORIZED_MESSAGE_ACCESS("L0002", "쪽지에 접근할 권한이 없습니다.", HttpStatus.FORBIDDEN),
    NICKNAME_ALREADY_EXISTS("M0002","이미 사용된 닉네임 입니다.", HttpStatus.BAD_REQUEST),
    MEMBER_ALREADY_EXISTS("M0001","이미 사용된 회원 ID 입니다.", HttpStatus.BAD_REQUEST),
    METHOD_NOT_ALLOWED("L0003", "지원하지 않는 메서드입니다.", HttpStatus.METHOD_NOT_ALLOWED),
    ;
    private final String code;
    private final String message;
    private final HttpStatus status;
}
