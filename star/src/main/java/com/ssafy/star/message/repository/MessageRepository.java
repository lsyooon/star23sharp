package com.ssafy.star.message.repository;

import com.ssafy.star.message.dto.response.ReceiveMessageResponse;
import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.dto.response.SendMessageResponse;
import com.ssafy.star.message.dto.response.SendMessageListResponse;
import com.ssafy.star.message.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    @Query("SELECT new com.ssafy.star.message.dto.response.ReceiveMessageListResponse(m.id, m.title, m.receiverType, m.sender.nickname, m.createdAt, m.isTreasure, mb.state) " +
            "FROM Message m JOIN MessageBox mb ON m.id = mb.message.id " +
            "WHERE m.id = :messageId AND mb.member.id = :memberId AND mb.isDeleted = false AND mb.messageDirection = 1 " +
            "ORDER BY m.createdAt DESC")
    List<ReceiveMessageListResponse> findReceiveMessageListByMessageIdAndMemberId(Long messageId, Long memberId);

    @Query("SELECT new com.ssafy.star.message.dto.response.SendMessageListResponse(m.id, m.title, m.receiverType, m.createdAt, m.isTreasure, m.isFound, m.group.id) " +
            "FROM Message m JOIN MessageBox mb ON m.id = mb.message.id " +
            "WHERE m.id = :messageId AND mb.member.id = :memberId AND mb.isDeleted = false AND mb.messageDirection = 0 " +
            "ORDER BY m.createdAt DESC")
    List<SendMessageListResponse> findSendMessageListByMessageIdAndMemberId(Long messageId, Long memberId);

    @Query("SELECT new com.ssafy.star.message.dto.response.ReceiveMessageResponse(m.id, m.sender.nickname, m.createdAt, m.title, m.content, m.image, m.isTreasure, m.receiverType, mb.isReported) " +
            "FROM Message m " +
            "JOIN MessageBox mb ON m.id = mb.message.id " +
            "WHERE m.id = :id AND mb.member.id = :memberId AND mb.messageDirection = :type")
    ReceiveMessageResponse findReceiveMessageById(Long id, Long memberId, short type);

    @Query("SELECT new com.ssafy.star.message.dto.response.SendMessageResponse(m.id, m.createdAt, m.title, m.content, m.image, m.isTreasure, m.receiverType, m.isFound, m.group.id)" +
            "FROM Message m WHERE m.id = :id")
    SendMessageResponse findSendMessageById(Long id);

    @Query("SELECT m.sender.id FROM Message m WHERE m.id = :messageId")
    Long findSenderIdByMessageId(Long messageId);

    boolean existsById(Long id);

    Message findMessageById(Long id);
}
