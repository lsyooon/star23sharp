package com.ssafy.star.message.entity;

import com.ssafy.star.member.entity.Member;
import lombok.*;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "complaint")
public class Complaint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "reporter_id", nullable = false, foreignKey = @ForeignKey(name = "fk_complaint_reporter"))
    private Member reporter;

    @ManyToOne
    @JoinColumn(name = "reported_id", nullable = false, foreignKey = @ForeignKey(name = "fk_complaint_reported"))
    private Member reported;

    @Column(nullable = false)
    private short state;

    @ManyToOne
    @JoinColumn(name = "message_id", nullable = false, foreignKey = @ForeignKey(name = "fk_complaint_message"))
    private Message message;

    @ManyToOne
    @JoinColumn(name = "complaint_reason_id", nullable = false, foreignKey = @ForeignKey(name = "fk_complaint_reason"))
    private ComplaintReason complaintReason;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
