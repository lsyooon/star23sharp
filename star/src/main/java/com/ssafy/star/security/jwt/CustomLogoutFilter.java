package com.ssafy.star.security.jwt;

import com.ssafy.star.security.entity.TokenEntity;
import com.ssafy.star.security.repository.TokenRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.filter.GenericFilterBean;

import java.io.IOException;
import java.io.PrintWriter;

@Slf4j
public class CustomLogoutFilter extends GenericFilterBean {

    private final JWTUtil jwtUtil;
    private final TokenRepository tokenRepository;

    public CustomLogoutFilter(JWTUtil jwtUtil, TokenRepository refreshRepository) {

        this.jwtUtil = jwtUtil;
        this.tokenRepository = refreshRepository;
    }


    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        doFilter((HttpServletRequest) request, (HttpServletResponse) response, chain);
    }
    private void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws IOException, ServletException {

        String requestUri = request.getRequestURI();
        if (!requestUri.matches("^\\/api/v1/logout$")) {

            filterChain.doFilter(request, response);
            return;
        }
        String requestMethod = request.getMethod();
        if (!requestMethod.equals("POST")) {

            filterChain.doFilter(request, response);
            return;
        }



        //get refresh token
        String refresh = null;
        refresh = request.getHeader("refresh");

        System.out.println(refresh);
        log.info("logout 들어옴");
        //refresh Token이 비어있는 경우
        if (refresh == null || refresh.trim().equals("")) {

            // 응답 상태 코드 설정
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");



            // 응답 메시지 작성
            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0007\", \"message\": \"Refresh Token이 비어있습니다.\", \"data\": null}");
            }
            return; // 필터 체인 종료

        }
        int validateJwt = jwtUtil.validateToken(refresh);
        if(validateJwt == 1) {
            // 응답 상태 코드 설정
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            log.info("토큰 검증 실패");
            // 응답 메시지 작성
            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0009\", \"message\": \"유효하지 않은 토큰입니다.\", \"data\": null }");
            }
            return;
        }
        if(validateJwt == 2){
            System.out.println("여기에걸림?");
            //refresh token을 보내달라
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 400 Bad Request
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0000\", \"message\": \"만료된 토큰입니다.\", \"data\": null }");
            }
            return; // 필터 체인 종료
        }


        // 만료된 경우
//        boolean isExpired = false;
//        try {
//            jwtUtil.isExpired(refresh);
//        } catch (ExpiredJwtException e) {
//            isExpired = true;
//        }

        // 토큰이 refresh인지 확인 (발급시 페이로드에 명시)
        String category = jwtUtil.getCategory(refresh);
        if (!category.equals("refresh")) {
            //refresh token을 보내달라
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 400 Bad Request
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0009\", \"message\": \"유효하지 않은 토큰입니다\", \"data\": null }");
            }
            return; // 필터 체인 종료
        }

        // refresh token에서 username 추출
        String username = jwtUtil.getMemberName(refresh);
        //DB에 저장되어 있는지 확인 후 없으면 OK return
        TokenEntity tokenEntity = tokenRepository.findById(username).orElse(null);
        // refresh 토큰이 달라
        if (tokenEntity != null && !tokenEntity.getToken().equals(refresh)) {
            // 만료 안된거면 탈취됐을 가능성이 높으므로 권한이 없다고 반환
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 400 Bad Request
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0009\", \"message\": \"유효하지 않은 토큰입니다.\", \"data\": null }");
            }
            return;
        }

        // 로그아웃 진행
        //Refresh 토큰 DB에서 제거
        tokenRepository.deleteById(username);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_OK); // 상태 코드 설정
        response.getWriter().write("{\"code\": \"200\", \"message\": \"로그아웃 성공\", \"data\": null }");
    }
}
