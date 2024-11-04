package com.ssafy.star.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration
@PropertySource(value="classpath:/application-secret.properties")
public class RedisConfig {


    @Value("${spring.data.redis.host}")
    private String host;
    @Value("${spring.data.redis.port}")
    private int port;
    @Value("${spring.data.redis.password}")
    private String password;


    @Bean
    public RedisConnectionFactory redisConnectionFactory() {
        // RedisStandaloneConfiguration에 호스트, 포트, 비밀번호 설정
        RedisStandaloneConfiguration redisConfig = new RedisStandaloneConfiguration();
        redisConfig.setHostName(host);
        redisConfig.setPort(port);
        redisConfig.setPassword(password); // 비밀번호 설정

        return new LettuceConnectionFactory(redisConfig);
    }

    @Bean
    public RedisTemplate<String, Object> redisTemplate() {
        RedisTemplate<String, Object> redisTemplate = new RedisTemplate<>();
        redisTemplate.setConnectionFactory(redisConnectionFactory());
//        // Value 직렬화 설정
//        // 문자열이아닌 TokenEntity로 직렬화 설정
//        PolymorphicTypeValidator typeValidator = BasicPolymorphicTypeValidator
//                .builder()
//                .allowIfSubType(TokenEntity.class)
//                .build();
//
//        // ObjectMapper 를 톻해  매핑
//        // configure => 알 수 없는 속성이 들어오는 경우 직렬화 하지 않도록 설정
//        // registerModule => 시간 데이터가 있는 경우 java.time 으로 직렬화하도록 설정
//        // activateDefaultTyping =>  ExchangeRates 역직렬화 유효성 검사 및 int, String, boolean, double 제외
//        // 모든 데이터 유형이 기본 유형이 되도록 지정
//        // disable => 날짜형 데이터 timestamp로 직렬화 되도록 설정
//        ObjectMapper objectMapper = new ObjectMapper()
//                .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES,false)
//                .registerModule(new JavaTimeModule())
//                .activateDefaultTyping(typeValidator,ObjectMapper.DefaultTyping.NON_FINAL)
//                .disable(SerializationFeature.WRITE_DATE_KEYS_AS_TIMESTAMPS);
//
//        GenericJackson2JsonRedisSerializer customSerializer = new GenericJackson2JsonRedisSerializer(objectMapper);

        //키 - 값 형태 시리얼라이저
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(new StringRedisSerializer());

        // Hash 자료형 시리얼라이저
        redisTemplate.setHashKeySerializer(new StringRedisSerializer());
        redisTemplate.setHashValueSerializer(new StringRedisSerializer());
//        redisTemplate.setHashValueSerializer(customSerializer);

        // 그 외
        redisTemplate.setDefaultSerializer(new StringRedisSerializer());

        return redisTemplate;
    }


}
