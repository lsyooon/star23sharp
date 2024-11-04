package com.ssafy.star.security.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@ToString
@RedisHash(value = "ref")
public class TokenEntity {

    @Id
    private String memberName;

    private String token;

    @TimeToLive
    private Long ttl;

    public void update(String token) {
        this.token = token;
    }

}
