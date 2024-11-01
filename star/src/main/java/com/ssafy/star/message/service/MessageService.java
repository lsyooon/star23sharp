package com.ssafy.star.message.service;

import com.ssafy.star.message.dto.response.ReceiveMessageList;
import com.ssafy.star.message.repository.MessageBoxRepository;
import com.ssafy.star.message.repository.MessageRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly=true)
public class MessageService {
    private MessageRepository messageRepository;
    private MessageBoxRepository messageBoxRepository;

//    public List<ReceiveMessageList> getReceiveMessageList(){
//
//        return ;
//    }

}
