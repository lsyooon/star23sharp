package com.ssafy.star.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class CustomException extends RuntimeException {

    private String errorCode;
    private HttpStatus status;

    public CustomException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public CustomException(CustomErrorCode customErrorCode) {
        super(customErrorCode.getMessage());
        this.errorCode = customErrorCode.getCode();
        this.status = customErrorCode.getStatus();
    }

    public CustomException(String errorCode, String message, HttpStatus httpStatus) {
       super(message);
        this.errorCode = errorCode;
        this.status = httpStatus;

    }
}
