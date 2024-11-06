package com.ssafy.star.member.repository;

import com.ssafy.star.member.dto.response.NotificationResponse;
import com.ssafy.star.member.dto.response.ReceiverTreasureNotificationResponse;
import com.ssafy.star.member.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    @Query("SELECT new com.ssafy.star.member.dto.response.NotificationResponse(n.id, n.title, n.content) " +
            "FROM Notification n WHERE n.member.id = :memberId AND n.message.id = :messageId")
    NotificationResponse findNotificationByMemberIdANDMessageId(Long memberId, Long messageId);

    @Query("SELECT new com.ssafy.star.member.dto.response.ReceiverTreasureNotificationResponse(n.id, n.title, n.content, m.hint, m.dotHintImage) " +
            "FROM Notification n JOIN n.message m " +
            "WHERE n.member.id = :memberId AND n.message.id = :messageId")
    ReceiverTreasureNotificationResponse findNotificationTreasureByMemberIdAndMessageId(Long memberId, Long messageId);
}
