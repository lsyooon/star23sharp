package com.ssafy.star.member.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import jakarta.persistence.*;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "nick_book")
public class NickBook {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false, foreignKey = @ForeignKey(name = "fk_nick_book_member"))
    private Member member;

    @Column(nullable = false)
    private String nickname;

    @Column
    private String name;

    public void modifyNickNameAndName(String nickname, String name) {
        this.nickname = nickname;
        this.name = name;
    }
}
