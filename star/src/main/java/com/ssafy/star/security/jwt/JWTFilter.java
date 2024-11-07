package com.ssafy.star.security.jwt;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.entity.Member;
import com.ssafy.star.security.dto.CustomUserDetails;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@Slf4j
public class JWTFilter extends OncePerRequestFilter {

    private final JWTUtil jwtUtil;

    // JWT 필터를 적용하지 않는 api endpoint
    // 화이트리스트 URL 목록
    private final List<String> whiteListedPaths = List.of(
            "/api/v1/login",
            "/api/v1/member/join",
            "/api/v1/refresh",
            "/api/v1/logout",
            "/api/v1/member/duplicate"
    );

    public JWTFilter(JWTUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }


    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {


        String requestURI = request.getRequestURI();
        if (whiteListedPaths.stream().anyMatch(requestURI::startsWith)) {
            log.info("jwt filter skip -> request url : {}", requestURI);
            filterChain.doFilter(request, response);
            return;
        }
        String accessToken = null;
        String authorizationHeader = request.getHeader("Authorization");
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            accessToken = authorizationHeader.substring(7);
        }

        // 토큰이 없다면 다음 필터로 넘김
        if (accessToken == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            // 응답 메시지 작성
            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0008\", \"message\": \"Access Token이 비어있습니다.\",\"data\": null }");
            }
            return;
        }
        int validateJwt = jwtUtil.validateToken(accessToken);
        if(validateJwt == 1) {
            // 응답 상태 코드 설정
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            // 응답 메시지 작성
            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0009\", \"message\": \"유효하지 않은 토큰입니다.\", \"data\": null }");
            }
            return;
        }else if(validateJwt == 2) {
            // 응답 상태 코드 설정
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            // 응답 메시지 작성
            try (PrintWriter writer = response.getWriter()) {
                writer.write("{\"code\": \"M0000\", \"message\": \"만료된 토큰입니다.\", \"data\": null }");
            }
            return;
        }
        // 토큰 만료 여부 확인, 만료시 다음 필터로 넘기지 않음
//        try {
//            jwtUtil.isExpired(accessToken);
//        } catch (ExpiredJwtException e) {
//            // 응답 상태 코드 설정
//            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
//            response.setContentType("application/json");
//            response.setCharacterEncoding("UTF-8");
//
//            // 응답 메시지 작성
//            try (PrintWriter writer = response.getWriter()) {
//                writer.write("{\"code\": \"M0000\", \"message\": \"만료된 토큰입니다.\", \"data\": null }");
//            }
//        }

        // 토큰이 access인지 확인 (발급시 페이로드에 명시)
        String category = jwtUtil.getCategory(accessToken);

        if (!category.equals("access")) {
           throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }
        try {
            // username, role 값을 획득
            String memberName = jwtUtil.getMemberName(accessToken);
            String role = jwtUtil.getRole(accessToken);
            Long id = jwtUtil.getId(accessToken);

            Member member = Member.builder().memberName(memberName).role(role).id(id).build();
            CustomUserDetails customUserDetails = new CustomUserDetails(member);

            Authentication authToken = new UsernamePasswordAuthenticationToken(customUserDetails, null, customUserDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(authToken);

            filterChain.doFilter(request, response);
        }
        catch (Exception e) {
            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }
    }
}
