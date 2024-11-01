package com.ssafy.star.message.repository;

import com.ssafy.star.message.entity.MessageBox;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageBoxRepository extends JpaRepository<MessageBox, Long> {
    List<Long> getMessageIdByMemberId(Long memberId);
}
