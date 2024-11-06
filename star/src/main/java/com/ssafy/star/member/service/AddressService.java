package com.ssafy.star.member.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.json.JSONArray;
import org.json.JSONObject;

@Service
public class AddressService {

    @Value("${kakao.rest.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String getAddressFromCoordinates(double latitude, double longitude) {
        String url = "https://dapi.kakao.com/v2/local/geo/coord2address.json";

        // 요청 URL 구성
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(url)
                .queryParam("x", longitude)
                .queryParam("y", latitude)
                .queryParam("input_coord", "WGS84");

        // 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "KakaoAK " + apiKey);

        // HttpEntity에 헤더 추가
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // API 요청 및 응답 처리
        ResponseEntity<String> response = restTemplate.exchange(
                uriBuilder.toUriString(), HttpMethod.GET, entity, String.class);

        if (response.getStatusCode() == HttpStatus.OK) {
            // JSON 파싱
            JSONObject jsonResponse = new JSONObject(response.getBody());
            JSONArray documents = jsonResponse.getJSONArray("documents");
            if (documents.length() > 0) {
                JSONObject addressObject = documents.getJSONObject(0);
                JSONObject roadAddress = addressObject.optJSONObject("road_address");

                // 도로명 주소가 존재하는 경우 가져오기
                if (roadAddress != null) {
                    return roadAddress.getString("address_name");
                } else {
                    JSONObject address = addressObject.getJSONObject("address");
                    return address.getString("address_name");
                }
            }
        }

        return "주소 정보를 찾을 수 없습니다.";
    }
}
