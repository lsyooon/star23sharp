package com.ssafy.star.message.repository;

import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("SELECT new com.ssafy.star.message.dto.response.ReceiveMessageListResponse(m.id, m.title, m.sender.nickname, m.createdAt, m.isTreasure) " +
            "FROM Message m WHERE m.id = :id ORDER BY m.createdAt DESC")
    List<ReceiveMessageListResponse> findReceiveMessageListById(Long id);
}
