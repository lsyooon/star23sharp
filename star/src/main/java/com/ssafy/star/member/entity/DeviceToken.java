package com.ssafy.star.member.entity;

import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;

@RedisHash("DeviceToken")
public class DeviceToken {

    @Id
    private String memberId;
    private String deviceToken;
    private boolean active;

    public DeviceToken(String memberId, String deviceToken) {
        this.memberId = memberId;
        this.deviceToken = deviceToken;
        this.active = true;
    }

    // getters and setters
    public String getMemberId() { return memberId; }
    public void setMemberId(String memberId) { this.memberId = memberId; }

    public String getDeviceToken() { return deviceToken; }
    public void setDeviceToken(String deviceToken) { this.deviceToken = deviceToken; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
