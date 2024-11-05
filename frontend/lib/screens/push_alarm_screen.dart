import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:star23sharp/utilities/index.dart';

class PushAlarmScreen extends StatefulWidget {
  const PushAlarmScreen({super.key});

  @override
  State<PushAlarmScreen> createState() => _PushAlarmScreenState();
}

class _PushAlarmScreenState extends State<PushAlarmScreen> {
  @override
  BuildContext context = AppGlobal.navigatorKey.currentState!
      .context; // use context from navigator key in app global class

  @override
  Widget build(BuildContext context) {
    Map payload = {};
    final data = ModalRoute.of(context)!.settings.arguments;
    if (data is RemoteMessage) {
      //백그라운드에서 푸시 알람을 탭할 때 처리
      payload = data.data;
    }
    if (data is NotificationResponse) {
      // 포그라운드에서 푸시 알람을 탭할 때 처리
      if (data.payload != null && data.payload!.isNotEmpty) {
        try {
          payload = jsonDecode(data.payload!);
        } catch (e) {
          print("JSON parsing error: $e");
          // 적절한 예외 처리
          payload = {}; // 기본값 설정
        }
      } else {
        print("Empty or null payload");
        payload = {}; // 기본값 설정
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Push Alarm Message')),
      body: Center(child: Text(payload.toString())),
    );
  }
}
