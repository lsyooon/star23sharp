package com.ssafy.star.message.entity;

import com.ssafy.star.member.entity.Member;
import com.ssafy.star.member.entity.MemberGroup;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "message_box")
public class MessageBox {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "message_id", nullable = false, foreignKey = @ForeignKey(name = "fk_message_box_message"))
    private Message message;

    @ManyToOne
    @JoinColumn(name = "member_id", nullable = false, foreignKey = @ForeignKey(name = "fk_message_box_member"))
    private Member member;

    @Column(name = "is_deleted", nullable = false)
    private boolean isDeleted = false;

    @Column(name = "message_direction", nullable = false)
    private short messageDirection;

    @Column
    private Boolean state = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "is_reported")
    private boolean isReported = false;

    public void setMember(Member member) {
        this.member = member;
    }

    public void setMessage(Message message) {
        this.message = message;
    }

    public void setMessageDirection(short messageDirection) {
        this.messageDirection = messageDirection;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
