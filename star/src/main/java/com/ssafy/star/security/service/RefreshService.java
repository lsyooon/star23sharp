package com.ssafy.star.security.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.security.jwt.JWTUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RefreshService {

    private final JWTUtil jwtUtil;
    private final TokenService tokenService;

    @Value("${jwt.access-token.expiration}")
    private Long accessTokenExpiration;

    @Value("${jwt.refresh-token.expiration}")
    private Long refreshTokenExpiration;


    public Map<String,String> updateToken(String refresh) {
        int validateJwt = jwtUtil.validateToken(refresh);
        if (validateJwt == 1) {

            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }
        if(validateJwt == 2){

            throw new CustomException(CustomErrorCode.EXPIRED_TOKEN);
        }
//        // refresh 토큰이 만료된 경우
//        try {
//            jwtUtil.isExpired(refresh);
//        } catch (ExpiredJwtException e) {
//
//           throw new CustomException(CustomErrorCode.EXPIRED_TOKEN);
//        }

        // 토큰이 refresh인지 확인 (발급시 페이로드에 명시)
        String category = jwtUtil.getCategory(refresh);

        // 유효한 토큰이지만 토큰이 refresh 토큰이 아닌 경우
        if (!category.equals("refresh")) {

            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        }

        String username = jwtUtil.getMemberName(refresh);
        String role = jwtUtil.getRole(refresh);
        Long id = jwtUtil.getId(refresh);

        // redis에 refresh 토큰이 없는 경우
        if(!tokenService.validateToken(username,refresh)){
            throw new CustomException(CustomErrorCode.INVALID_TOKEN);
        };
        //새로운 access 토큰 생성
        String newAccess = jwtUtil.createJwt("access", username,id, role, accessTokenExpiration);
        String newRefresh = jwtUtil.createJwt("refresh", username,id, role, refreshTokenExpiration);


        tokenService.updateRefreshToken(username, newRefresh,refreshTokenExpiration);

        Map<String,String> map = new HashMap<>();
        map.put("access", newAccess);
        map.put("refresh",newRefresh);
        return map;
    }
}
