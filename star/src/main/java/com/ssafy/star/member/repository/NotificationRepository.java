package com.ssafy.star.member.repository;

import com.ssafy.star.member.dto.response.NotificationListResponse;
import com.ssafy.star.member.dto.response.NotificationResponse;
import com.ssafy.star.member.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    @Query("SELECT new com.ssafy.star.member.dto.response.NotificationListResponse(n.id, n.title, n.createdAt, n.isRead) " +
            "FROM Notification n WHERE n.member.id = :memberId ORDER BY n.createdAt DESC")
    List<NotificationListResponse> getNotificationListByMemberId(Long memberId);

    @Query("SELECT new com.ssafy.star.member.dto.response.NotificationResponse(n.id, n.title, n.content, n.hint, n.image, n.createdAt ) " +
            "FROM Notification n WHERE n.id = :id")
    NotificationResponse getNotificationById(Long id);

    @Query("SELECT CASE WHEN COUNT(n) > 0 THEN true ELSE false END FROM Notification n WHERE n.member.id = :memberId AND n.id = :id")
    boolean existsByMemberIdAndId(Long memberId, Long id);

    @Transactional
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true WHERE n.id = :id")
    void updateIsReadById(Long id);
}
