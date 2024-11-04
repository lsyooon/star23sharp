package com.ssafy.star.security.repository;

import com.ssafy.star.security.entity.TokenEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface TokenRepository extends CrudRepository<TokenEntity, String> {

    // Refresh token
    Optional<TokenEntity> findByUsernameWith(String token);

    Optional<TokenEntity> findByMembername(String memberName);



}
