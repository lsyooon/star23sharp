package com.ssafy.star.member.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "member_group")
public class MemberGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "group_name", length = 15)
    private String groupName;

    @ManyToOne
    @JoinColumn(name = "creator_id", nullable = false, foreignKey = @ForeignKey(name = "fk_member_group_creator"))
    private Member creator;

    @Column(name = "is_favorite", nullable = false)
    private boolean isFavorite = false;

    @Column(name = "is_constructed", nullable = false)
    private boolean isConstructed = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}

