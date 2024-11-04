package com.ssafy.star.security.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.security.entity.TokenEntity;
import com.ssafy.star.security.repository.TokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TokenService {

    private final RedisTemplate<String, Object> redisTemplate;

    private final TokenRepository tokenRepository;

    public boolean validateToken(String username, String refresh){

        TokenEntity preToken = tokenRepository.findById(username).orElseThrow(
                () -> new CustomException(CustomErrorCode.EXPIRED_TOKEN)
        );
        if (preToken.getToken().equals(refresh)) {
            return true;
        }
        return false;
    }

    public void updateRefreshToken(String username, String refreshToken, Long refreshTokenExpireTime) {

        TokenEntity tokenEntity = new TokenEntity(username, refreshToken, refreshTokenExpireTime);
        tokenRepository.save(tokenEntity);
    }

    public void deleteRefreshToken(String username, String refreshToken) {
        TokenEntity tokenEntity = tokenRepository.findById(username).orElse(null);
        if (tokenEntity != null) {
            tokenRepository.delete(tokenEntity);
        }
    }
}
