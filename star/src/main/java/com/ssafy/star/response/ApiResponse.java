package com.ssafy.star.response;

import com.ssafy.star.exception.CustomErrorCode;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ApiResponse<T> {

    private String code;

    private String message;

    private T data;

    public ApiResponse(String code, String message) {
        this.code = code;
        this.message = message;
    }

    // 실패 응답
    public static ApiResponse<Void> isError(CustomErrorCode errorCode) {
        return new ApiResponse<>(errorCode.getCode(), errorCode.getMessage());
    }

}
