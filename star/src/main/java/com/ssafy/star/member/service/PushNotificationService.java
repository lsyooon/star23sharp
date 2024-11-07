package com.ssafy.star.member.service;

import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;

@Service
public class PushNotificationService {

    private final FirebaseMessaging firebaseMessaging;

    public PushNotificationService(FirebaseMessaging firebaseMessaging) {
        this.firebaseMessaging = firebaseMessaging;
    }

    @Async
    public void sendPushNotification(String token, String id, String title, String content) {

        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(content)
                .build();

        Message message = Message.builder()
                .setToken(token)
                .putData("notificationId", id)
                .setNotification(notification)
                .build();

        try {
            firebaseMessaging.send(message);
        } catch (FirebaseMessagingException e) {
            // Firebase 관련 예외 처리
            if (e.getMessage().contains("Invalid registration token")) {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_INVALID_TOKEN);
            } else if (e.getMessage().contains("Registration token is not valid")) {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_EXPIRED_TOKEN);
            } else if (e.getMessage().contains("Message payload is too large")) {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_MESSAGE_TOO_LARGE);
            } else {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_AUTH_ERROR);
            }
        } catch (Exception e) {
            // 기타 예외 처리
            throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_FAILED);
        }
    }

    @Async
    public void sendPushNotification(String token, String title, String content, String id, String hint, String image) {

        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(content + "\n" + hint)
                .setImage(image)
                .build();

        Message message = Message.builder()
                .setToken(token)
                .putData("notificationId", id)
                .setNotification(notification)
                .build();

        try {
            firebaseMessaging.send(message);
        } catch (FirebaseMessagingException e) {
            // Firebase 관련 예외 처리
            if (e.getMessage().contains("Invalid registration token")) {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_INVALID_TOKEN);
            } else if (e.getMessage().contains("Registration token is not valid")) {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_EXPIRED_TOKEN);
            } else if (e.getMessage().contains("Message payload is too large")) {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_MESSAGE_TOO_LARGE);
            } else {
                throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_AUTH_ERROR);
            }
        } catch (Exception e) {
            // 기타 예외 처리
            throw new CustomException(CustomErrorCode.PUSH_NOTIFICATION_FAILED);
        }
    }
}
