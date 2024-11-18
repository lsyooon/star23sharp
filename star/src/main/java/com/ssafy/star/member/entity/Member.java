package com.ssafy.star.member.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "member")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "member_name", nullable = false, unique = true)
    private String memberName;

    @Column(nullable = false)
    private String password;

    @Column(name = "complaint_count", nullable = false)
    private int complaintCount = 0;

    @Column(nullable = false)
    private short state = 0;

    @Column(nullable = false, unique = true)
    private String nickname;

    @Column(name = "reactivation_date")
    private LocalDateTime reactivationDate;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name= "role", nullable = false)
    private String role;

    @Column(name = "is_push_notification_enabled")
    private boolean isPushNotificationEnabled = false;
}

