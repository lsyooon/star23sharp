package com.ssafy.star.message.repository;

import com.ssafy.star.message.entity.MessageBox;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface MessageBoxRepository extends JpaRepository<MessageBox, Long> {
    @Query("SELECT mb.message.id FROM MessageBox mb WHERE mb.member.id = :memberId AND mb.messageDirection = :type")
    List<Long> getMessageIdByMemberId(Long memberId, short type);
}