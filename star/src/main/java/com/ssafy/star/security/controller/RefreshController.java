package com.ssafy.star.security.controller;


import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.jwt.JWTUtil;
import com.ssafy.star.security.service.RefreshService;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class RefreshController {

    private final JWTUtil jwtUtil;
    private final ServletRequest httpServletRequest;

    private final RefreshService refreshService;


    @PostMapping("/api/v1/refresh")
    public ResponseEntity<?> refresh(HttpServletRequest req, HttpServletResponse res) {

            //요청 쿠키에서 refresh 키 찾아서 값 꺼내옴
            String refresh = null;
            refresh = req.getHeader("refresh");

            // refresh 토큰이 없는 경우
            if (refresh == null || refresh.trim().equals("")) {

                return new ResponseEntity<>(new ApiResponse<>("M0007","Refresh Token이 비어있습니다.", null), HttpStatus.UNAUTHORIZED);
            }
            Map<String,String> tokens = refreshService.updateToken(refresh);
            //response
            res.setHeader("access", tokens.get("access"));
            res.setHeader("refresh" ,tokens.get("refresh"));

            return new ResponseEntity<>(new ApiResponse<>("200","Token 재발급 성공"),HttpStatus.OK);

//            System.out.println(e.getMessage());
//            return new ResponseEntity<>(new ApiResponse<>("E0000","서버 에러가 발생했습니다.", null), HttpStatus.INTERNAL_SERVER_ERROR);


    }

    @PostMapping("/api/v1/admin")
    public ResponseEntity<?> admin(HttpServletRequest req, HttpServletResponse res) {

       return ResponseEntity.status(HttpStatus.OK).build();


    }

    @PostMapping("/api/v1/user")
    public ResponseEntity<?> user(HttpServletRequest req, HttpServletResponse res) {

        return ResponseEntity.status(HttpStatus.OK).build();


    }


    private Cookie createCookie(String key, String value) {

        Cookie cookie = new Cookie(key, value);
        cookie.setMaxAge(24*60*60);
        //cookie.setSecure(true);
        //cookie.setPath("/");
        cookie.setHttpOnly(true);

        return cookie;
    }
}
