package com.ssafy.star.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

// CORS 설정
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*") // 특정 도메인 허용 설정
                .allowedMethods("GET", "POST","DELETE","PUT"); // 허용할 HTTP method 지정
//                .allowCredentials(true); // 쿠키 인증 요청 허용
    }
}