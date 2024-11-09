package com.ssafy.star.config;

import com.ssafy.star.member.service.NotificationService;
import com.ssafy.star.security.jwt.CustomLogoutFilter;
import com.ssafy.star.security.jwt.JWTFilter;
import com.ssafy.star.security.jwt.JWTUtil;
import com.ssafy.star.security.jwt.LoginFilter;
import com.ssafy.star.security.repository.TokenRepository;
import com.ssafy.star.security.service.TokenService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Validator;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.LogoutFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.Collections;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    //AuthenticationManager가 인자로 받을 AuthenticationConfiguraion 객체 생성자 주입
    private final AuthenticationConfiguration authenticationConfiguration;

    private final JWTUtil jwtUtil;

    private final TokenService tokenService;

    private final TokenRepository tokenRepository;

    private final Long accessTokenExpiration;

    private final Long refreshTokenExpiration;

    private final Validator validator;

    private final NotificationService notificationService;

    public SecurityConfig(AuthenticationConfiguration authenticationConfiguration, JWTUtil jwtUtil, TokenService tokenService,
                          @Value("${jwt.access-token.expiration}") Long accessTokenExpiration,
                          @Value("${jwt.refresh-token.expiration}") Long refreshTokenExpiration, TokenRepository tokenRepository, Validator validator, NotificationService notificationService) {

        this.authenticationConfiguration = authenticationConfiguration;
        this.jwtUtil = jwtUtil;
        this.tokenService = tokenService;
        this.accessTokenExpiration = accessTokenExpiration;
        this.refreshTokenExpiration = refreshTokenExpiration;
        this.tokenRepository = tokenRepository;
        this.validator = validator;
        this.notificationService = notificationService;
    }

    //AuthenticationManager Bean 등록
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {

        return configuration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }


    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        // cors 설정
        http
                .cors((corsCustomizer -> corsCustomizer.configurationSource(new CorsConfigurationSource() {

                    @Override
                    public CorsConfiguration getCorsConfiguration(HttpServletRequest request) {

                        CorsConfiguration configuration = new CorsConfiguration();

                        //
                        configuration.setAllowedOrigins(Collections.singletonList("*"));
                        // 모든 HTTP 메서드
                        configuration.setAllowedMethods(Collections.singletonList("*"));
                        configuration.setAllowCredentials(true);
                        // 허용할 헤더 설정
                        configuration.setAllowedHeaders(Collections.singletonList("*"));
                        configuration.setMaxAge(3600L);
                        // Authorization 헤더도 허용 시킴
                        configuration.setExposedHeaders(Collections.singletonList("Authorization"));

                        return configuration;
                    }
                })));

        //csrf disable => session을 stateless 로 설정하기 때문
        http.csrf((auth) -> auth.disable());

        // Form 로그인 ,  http basic 인증 방식 disable
        http.formLogin((auth) -> auth.disable());

        http.httpBasic((auth) -> auth.disable());

        http.authorizeHttpRequests((auth) -> auth
                .requestMatchers("/api/v1/login", "/", "/api/v1/member/join","/api/v1/refresh","api/v1/member/duplicate").permitAll()
                .requestMatchers("/api/v1/admin").hasRole("ADMIN")
                .anyRequest().authenticated()
        );

        http.addFilterBefore(new JWTFilter(jwtUtil), LoginFilter.class);


        LoginFilter loginFilter = new LoginFilter(authenticationManager(authenticationConfiguration), jwtUtil, tokenService, accessTokenExpiration, refreshTokenExpiration, validator);
        loginFilter.setFilterProcessesUrl("/api/v1/login");
        http.addFilterAt(loginFilter, UsernamePasswordAuthenticationFilter.class);

        http
                .addFilterBefore(new CustomLogoutFilter(jwtUtil, tokenRepository,notificationService), LogoutFilter.class);
        // session 을 stateless 로 설정
        http.sessionManagement((session) -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS));


        return http.build();
    }

}
