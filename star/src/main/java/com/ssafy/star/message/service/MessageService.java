package com.ssafy.star.message.service;

import com.ssafy.star.member.repository.MemberGroupRepository;
import com.ssafy.star.message.dto.response.ReceiveMessageListResponse;
import com.ssafy.star.message.dto.response.SendMessageListResponse;
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
    private final MessageRepository messageRepository;
    private final MessageBoxRepository messageBoxRepository;
    private final MemberGroupRepository memberGroupRepository;

    public MessageService(MessageRepository messageRepository, MessageBoxRepository messageBoxRepository, MemberGroupRepository memberGroupRepository) {
        this.messageRepository = messageRepository;
        this.messageBoxRepository = messageBoxRepository;
        this.memberGroupRepository = memberGroupRepository;
    }

    public List<ReceiveMessageListResponse> getReceiveMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 1);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<ReceiveMessageListResponse> list = new ArrayList<>();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<ReceiveMessageListResponse> messages = messageRepository.findReceiveMessageListById(messageId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

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


    public List<SendMessageListResponse> getSendMessageList(Long userId) {
        List<Long> messageIdList = messageBoxRepository.getMessageIdByMemberId(userId, (short) 0);
        if (messageIdList == null || messageIdList.isEmpty()) {
            return new ArrayList<>();
        }

        List<SendMessageListResponse> list = new ArrayList<>();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        LocalDateTime now = LocalDateTime.now();

        for (Long messageId : messageIdList) {
            List<SendMessageListResponse> messages = messageRepository.findSendMessageListById(messageId);

            if (messages == null) {
                messages = new ArrayList<>();
            }

            // 날짜 포맷 처리
            for (SendMessageListResponse message : messages) {
                LocalDateTime createdAt = message.getCreatedAt();
                String formattedDate = createdAt.toLocalDate().isEqual(now.toLocalDate())
                        ? createdAt.format(timeFormatter) // 오늘 날짜면 시간만
                        : createdAt.format(dateFormatter); // 오늘 이전 날짜면 날짜만
                message.setCreatedDate(formattedDate); // 변환된 날짜 설정
                if (message.getReceiverType() == (short) 0) {
                    message.setRecipient(messageBoxRepository.getRecipientNameByMessageId(message.getMessageId(), (short) 1));
                } else if (message.getReceiverType() == (short) 1) {
                    String recipient = messageBoxRepository.findMemberNicknameByMessageId(message.getMessageId(), (short) 1) + " 외 "
                            + (messageBoxRepository.getMemberCountByMessageId(message.getMessageId(), (short) 1) - 1) + "명";
                    if (message.getGroupId() != null) {
                        Boolean isConstructed = memberGroupRepository.findIsConstructedByGroupId(message.getGroupId());
                        if (isConstructed != null && isConstructed) {
                            recipient = memberGroupRepository.findGroupNameById(message.getGroupId());
                        }
                    }
                    message.setRecipient(recipient);
                } else {
                    message.setRecipient("모두에게");
                }
            }
            list.addAll(messages);
        }
        return list;
    }

}
