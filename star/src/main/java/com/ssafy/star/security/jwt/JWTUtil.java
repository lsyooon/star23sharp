package com.ssafy.star.security.jwt;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import io.jsonwebtoken.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.List;

@Component
@Slf4j
public class JWTUtil {

    private SecretKey secretKey;

    public JWTUtil(@Value("${spring.jwt.secret}") String secretKey) {
        this.secretKey = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), Jwts.SIG.HS256.key().build().getAlgorithm());
    }

    //JWT Token 유효성 검사
    public int validateToken(String token) {
        try {
            if(Jwts.parser().
                    verifyWith(secretKey)
                    .build()
                    .parseClaimsJws(token)
                    .getPayload()
                    .keySet()
                    .containsAll(List.of("memberName", "role", "category","memberId"))){
                return 0;
            }
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            log.info("Invalid JWT Token", e.getMessage());
            return 1;

        } catch (ExpiredJwtException e) {
            log.info("Expired JWT Token", e.getMessage());
            return 2;
        }
        catch (UnsupportedJwtException e) {
            log.info("Unsupported JWT Token", e.getMessage());
            return 1;
        } catch (IllegalArgumentException e) {
            log.info("JWT claims string is empty.", e.getMessage());
            return 1;
        }
            return 1;
    }

    // jwt token의 payload 에서 username 추출
    public String getMemberName(String token) {

        try {
            return Jwts.parser().
                    verifyWith(secretKey)
                    .build()
                    .parseClaimsJws(token)
                    .getPayload()
                    .get("memberName", String.class);
        } catch (JwtException e) {
            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }
    }

    // jwt token의 payload 에서 role 추출
    public String getRole(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseClaimsJws(token)
                    .getPayload()
                    .get("role", String.class);
        } catch (JwtException e) {
            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }

    }

    // jwt token의 payload 에서 token category 추출
    public String getCategory(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload()
                    .get("category", String.class);
        } catch (JwtException e) {
            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }
    }

    public Long getId(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload()
                    .get("memberId", Long.class);
        } catch (JwtException e) {
            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }
    }

    // 토큰 만료 확인
    public Boolean isExpired(String token) {

            return Jwts.parser()
                    .verifyWith(secretKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload()
                    .getExpiration()
                    .before(new Date());


    }

    public String createJwt(String category, String memberName,Long memberId, String role, Long expiredMs) {
        return Jwts.builder()
                .claim("category", category)
                .claim("memberName", memberName)
                .claim("role", role)
                .claim("memberId", memberId)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expiredMs))
                .signWith(secretKey)
                .compact();
    }
}
