package com.ssafy.star.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum CustomErrorCode {
    MAX_UPLOAD_SIZE_EXCEEDED("E0003", "업로드 가능한 파일 크기를 초과했습니다.", HttpStatus.PAYLOAD_TOO_LARGE);
    private final String code;
    private final String message;
    private final HttpStatus status;

}
