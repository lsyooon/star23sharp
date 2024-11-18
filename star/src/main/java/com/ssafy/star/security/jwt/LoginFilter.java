package com.ssafy.star.security.jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.star.response.ApiResponse;
import com.ssafy.star.security.dto.CustomUserDetails;
import com.ssafy.star.security.dto.LoginDto;
import com.ssafy.star.security.service.TokenService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Validator;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.util.StreamUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.Iterator;

@Slf4j
public class LoginFilter extends UsernamePasswordAuthenticationFilter {

    private final AuthenticationManager authenticationManager;

    private final Long accessTokenExpiration;

    private final Long refreshTokenExpiration;
    private final JWTUtil jwtUtil;

    private final TokenService tokenService;

    private final Validator validator;

    public LoginFilter(AuthenticationManager authenticationManager, JWTUtil jwtUtil, TokenService tokenService, Long accessTokenExpiration, Long refreshTokenExpiration, Validator validator) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.tokenService = tokenService;
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
        this.validator = validator;

    }

    // 클라이언트 요청을 가로채서 아이디 비밀번호 확인
    @Override
    public Authentication attemptAuthentication(HttpServletRequest req, HttpServletResponse res) throws AuthenticationException {


        LoginDto loginDTO = new LoginDto();
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            ServletInputStream inputStream = req.getInputStream();
            String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
            loginDTO = objectMapper.readValue(messageBody, LoginDto.class);

        } catch (IOException e) {
            log.error("Login Filter Error : {}", e.getMessage());
        }

        String memberName = loginDTO.getMemberId();
        String password = loginDTO.getPassword();
        UsernamePasswordAuthenticationToken authRequest =
                new UsernamePasswordAuthenticationToken(memberName, password, null);

        return authenticationManager.authenticate(authRequest);
    }

    // 로그인 성공시 호출되는 메서드
    @Override
    protected void successfulAuthentication(HttpServletRequest req, HttpServletResponse res, FilterChain chain,
                                            Authentication authentication) throws IOException {
        //유저 정보
        String memberName = authentication.getName();
// UserDetails 객체에서 사용자 정보를 가져오기
        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        Long memberId = userDetails.getId(); // ID 가져오기
        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        Iterator<? extends GrantedAuthority> iterator = authorities.iterator();
        GrantedAuthority auth = iterator.next();
        String role = auth.getAuthority();

        //토큰 생성
        String access = jwtUtil.createJwt("access", memberName,memberId, role, accessTokenExpiration);
        String refresh = jwtUtil.createJwt("refresh", memberName,memberId, role, refreshTokenExpiration);


        tokenService.updateRefreshToken(memberName, refresh, refreshTokenExpiration);


        ObjectMapper objectMapper = new ObjectMapper();
        String responseBody = objectMapper.writeValueAsString(new ApiResponse<>("200","로그인 성공"));

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setStatus(HttpServletResponse.SC_OK);
        res.setHeader("access",access);// 상태 코드 설정
        res.setHeader("refresh",refresh);// 상태 코드 설정
        res.getWriter().write(responseBody);
    }

    // 로그인 실패시 호출되는 메서드
    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest req, HttpServletResponse res, AuthenticationException failed) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        String responseBody = objectMapper.writeValueAsString(new ApiResponse<>("M0004","회원 정보가 일치하지 않습니다."));

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 상태 코드 설정
        res.getWriter().write(responseBody);

    }

}
