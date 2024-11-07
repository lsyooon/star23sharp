import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

import 'package:star23sharp/main.dart';
import 'package:star23sharp/utilities/index.dart';

//포그라운드로 알림을 받아서 알림을 탭했을 때 페이지 이동
@pragma('vm:entry-point')
void onNotificationTap(NotificationResponse notificationResponse) {
  AppGlobal.navigatorKey.currentState!
      .pushNamed('/notification', arguments: notificationResponse);
}

class PushNotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _token;
  //권한 요청
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    try {
      _token = await FirebaseMessaging.instance.getToken();
      logger.d("내 디바이스 토큰: $_token");
    } catch (e) {
      logger.e("Error getting token: $e");
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
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('pomo_timer_alarm_1', 'pomo_timer_alarm',
            channelDescription: '',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }

  //API를 이용한 발송 요청
  static Future<void> send(
      {required String title, required String message}) async {
    final jsonCredentials =
        await rootBundle.loadString('assets/data/firebaseAuth.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);
    final client = await auth.clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    final notificationData = {
      'message': {
        'token': _token, //기기 토큰
        'data': {
          //payload 데이터 구성
          'via': 'FlutterFire Cloud Messaging!!!',
        },

        'notification': {
          'title': title, //푸시 알림 제목
          'body': message, //푸시 알림 내용
        }
      },
    };
    final response = await client.post(
      //FIXME - admin senderId env파일에 넣기
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/0bbcc74abaea1b06086cecee7880eab57fe7f90e/messages:send'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(notificationData),
    );

    client.close();
    if (response.statusCode == 200) {
      debugPrint(
          'FCM notification sent with status code: ${response.statusCode}');
    } else {
      debugPrint(
          '${response.statusCode} , ${response.reasonPhrase} , ${response.body}');
    }
  }
}
