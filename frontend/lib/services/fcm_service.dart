import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/services/index.dart';

//포그라운드로 알림을 받아서 알림을 탭했을 때 페이지 이동
@pragma('vm:entry-point')
void onNotificationTap(NotificationResponse notificationResponse) {
  try {
    // 데이터에서 notificationId 추출
    final payload = notificationResponse.payload;
    final Map<String, dynamic> parsedPayload =
        payload != null ? jsonDecode(payload) : {};
    final notificationId = parsedPayload['notificationId'];
    final messageId = parsedPayload['messageId'];

    // Navigator 상태 확인
    if (notificationId == null) {
      logger.e("Notification ID is missing in the payload.");
      return;
    }
    if (AppGlobal.navigatorKey.currentState == null) {
      logger.e("Navigator key is not initialized.");
      return;
    }
    logger.d(" 포그라운드 fcm service:onNotification 아이디는:  " + notificationId);
    final isLoggedIn = Provider.of<AuthProvider>(
            AppGlobal.navigatorKey.currentContext!,
            listen: false)
        .isLoggedIn;
    if (isLoggedIn) {
      if (messageId != null) {
        logger.d("알림 messageId: $messageId");
        AppGlobal.navigatorKey.currentState!.pushNamed(
          '/star_received_detail',
          arguments: int.tryParse(messageId), // messageId 전달
        );
        return;
      }
      final currentState = AppGlobal.navigatorKey.currentState;
      if (currentState != null) {
        String? currentPath;
        currentState.popUntil((route) {
          currentPath = route.settings.name;
          return true;
        });
        logger.d("현재 화면 url: $currentPath");

        // 현재 화면이 '/notification'인 경우 fetchNotifications 호출
        if (currentPath != '/notification') {
          AppGlobal.navigatorKey.currentState!.pushNamed(
            '/notification',
            arguments: int.tryParse(notificationId), // notificationId를 전달
          );
        }
      }
    } else {
      AppGlobal.navigatorKey.currentState!.pushNamed(
        '/signin',
      );
    }
  } catch (e) {
    logger.e("Failed to parse notification payload: $e");
  }
}

class FCMService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _token;
  //권한 요청
  static Future init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // 권한이 거부된 경우 처리
      logger.w("푸시 알림 권한이 거부되었습니다.");

      Provider.of<UserProvider>(AppGlobal.navigatorKey.currentContext!,
              listen: false)
          .setPushNotificationEnabled(false);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      // 권한 상태가 결정되지 않은 경우
      logger.w("푸시 알림 권한 상태가 결정되지 않았습니다.");
    } else {
      // 권한이 허용된 경우
      logger.d("푸시 알림 권한이 허용되었습니다.");

      try {
        _token = await FirebaseMessaging.instance.getToken();
        logger.d("내 디바이스 토큰: $_token");
      } catch (e) {
        logger.e("Error getting token: $e");
      }
    }
  }

  //flutter_local_notifications 패키지 관련 초기화
  static Future localNotiInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  //포그라운드에서 푸시 알림을 전송받기 위한 패키지 푸시 알림 발송
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
    required int notificationId,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('pomo_timer_alarm_1', 'pomo_timer_alarm',
            channelDescription: '',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

//포그라운드에서 푸시 알림을 전송받기 위한 패키지 푸시 알림 발송
  static Future showImageNotification({
    required String title,
    required String body,
    required String imageUrl,
    required String payload,
    required int notificationId,
  }) async {
    final localImagePath = await FCMService.downloadImage(imageUrl);
    logger.d('Image downloaded to: $localImagePath');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(localImagePath), // 이미지 경로
      largeIcon: FilePathAndroidBitmap(localImagePath),
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'image_channel', // 채널 ID
      'Image Notifications', // 채널 이름
      channelDescription: 'Channel for image notifications',
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      notificationId, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // 이미지 다운로드 함수
  static Future<String> downloadImage(String imageUrl) async {
    try {
      final dio = DioService.dio;
      final documentDirectory = (await getApplicationDocumentsDirectory()).path;
      final filePath = '$documentDirectory/notification_image.jpg';

      // 이미지 다운로드
      await dio.download(
        imageUrl, // 다운로드 URL
        filePath, // 저장할 파일 경로
        onReceiveProgress: (received, total) {},
      );

      return filePath; // 다운로드된 파일 경로 반환
    } catch (e) {
      throw Exception('Image download failed: $e');
    }
  }
}
