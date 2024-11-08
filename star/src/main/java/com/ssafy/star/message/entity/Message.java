package com.ssafy.star.message.entity;

import com.ssafy.star.member.entity.Member;
import com.ssafy.star.member.entity.MemberGroup;
import io.hypersistence.utils.hibernate.type.array.ListArrayType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "message")
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    private Member sender;

    @Column(name="receiver_type", nullable = false)
    private short receiverType = 0;

    @Column(name = "hint_image_first")
    private String hintImageFirst;
    @Column(name = "hint_image_second")
    private String hintImageSecond;
    @Column(name = "dot_hint_image")
    private String dotHintImage;

    @Column(nullable = false)
    private String title;

    @Column
    private String content;

    @Column
    private String hint;

    @Column
    private Float lat;
    @Column
    private Float lng;
//    @Column
//    @JdbcTypeCode(SqlTypes.VECTOR)
//    @Array(length = 3)
//    private Float[] coordinate;

    @Column(name = "is_treasure", nullable = false)
    private boolean isTreasure = false;

    @Column(name = "is_found", nullable = false)
    private boolean isFound = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column
    private String image;

//    @Column
//    @JdbcTypeCode(SqlTypes.VECTOR)
//    @Array(length = 12288)
//    private Float[] vector;

    @ManyToOne
    @JoinColumn(name = "group_id", foreignKey = @ForeignKey(name = "fk_message_group"))
    private MemberGroup group;

    @Type(ListArrayType.class)
    @Column(
            name = "receiver",
            columnDefinition = "bigint[]"
    )
    private List<Long> receiver;

}
