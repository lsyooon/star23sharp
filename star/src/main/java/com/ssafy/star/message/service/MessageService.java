package com.ssafy.star.message.service;

import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.repository.MessageBoxRepository;
import com.ssafy.star.message.repository.MessageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class MessageService {
    private MessageRepository messageRepository;
    private MessageBoxRepository messageBoxRepository;

    public List<ReceiveMessageListResponse> getReceiveMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId);
        List<ReceiveMessageListResponse> list = new ArrayList<>();

        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm:ss");
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<ReceiveMessageListResponse> messages = messageRepository.findReceiveMessageListById(messageId);

            // 날짜 포맷 처리
            for (ReceiveMessageListResponse message : messages) {
                LocalDateTime createdAt = message.getCreatedAt();
                String formattedDate = createdAt.toLocalDate().isEqual(now.toLocalDate())
                        ? createdAt.format(timeFormatter) // 오늘 날짜면 시간만
                        : createdAt.format(dateFormatter); // 오늘 이전 날짜면 날짜만
                message.setCreatedDate(formattedDate); // 변환된 날짜 설정
            }
            list.addAll(messages);
        }
        return list;
    }

}
