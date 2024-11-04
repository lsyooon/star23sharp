package com.ssafy.star.exception.controller;

import com.ssafy.star.exception.CustomException;
import com.ssafy.star.response.ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class CustomExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<?> handleCustomException(CustomException e) {
        log.info("[handleCustomException] = {}", e.getMessage());
        String message = e.getMessage();
        String errorCode = e.getErrorCode();
        return ResponseEntity
                .status(e.getStatus())
                .body(new ApiResponse<Void>(errorCode, message));
    }

//    @ExceptionHandler(MaxUploadSizeExceededException.class)
//    public ResponseEntity<?> handleMaxSizeException(MaxUploadSizeExceededException e) {
//        log.info("[handleMaxSizeException] = 파일 크기 초과");
//        CustomErrorCode errorCode = CustomErrorCode.MAX_UPLOAD_SIZE_EXCEEDED;
//        return ResponseEntity
//                .status(errorCode.getStatus())
//                .body(new ApiResponse<Void>(errorCode.getCode(), errorCode.getMessage()));
//    }

}
