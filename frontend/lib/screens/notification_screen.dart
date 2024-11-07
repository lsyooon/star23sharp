import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/widgets/index.dart';

class PushAlarmScreen extends StatefulWidget {
  const PushAlarmScreen({super.key});

  @override
  State<PushAlarmScreen> createState() => _PushAlarmScreenState();
}

class _PushAlarmScreenState extends State<PushAlarmScreen> {
  @override
  BuildContext context = AppGlobal.navigatorKey.currentState!
      .context; // use context from navigator key in app global class

  List<NotificationModel> notifications = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final fetchedNotifications = await NotificationService.getNotifications();

    setState(() {
      notifications = fetchedNotifications;
      isLoading = false;
    });
  }

  Future<void> _fetchNotificationDetail(int notificationId) async {
    final notificationDetail =
        await NotificationService.getNotificationDetail(notificationId);

    if (notificationDetail != null) {
      logger.d(notificationDetail);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notificationDetail.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notificationDetail.content),
              if (notificationDetail.hint != null) ...[
                const SizedBox(height: 10),
                Text("${notificationDetail.hint}"),
              ],
              if (notificationDetail.image != null) ...[
                const SizedBox(height: 10),
                Image.network(notificationDetail.image!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
    } else {
      logger.e('알림 상세 정보를 불러오는 데 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map payload = {};
    final data = ModalRoute.of(context)!.settings.arguments;
    if (data is RemoteMessage) {
      // 백그라운드에서 푸시 알람을 탭할 때 처리
      payload = data.data;
    }
    if (data is NotificationResponse) {
      // 포그라운드에서 푸시 알람을 탭할 때 처리
      if (data.payload != null && data.payload!.isNotEmpty) {
        try {
          payload = jsonDecode(data.payload!);
        } catch (e) {
          logger.e("JSON parsing error: $e");
          payload = {}; // 기본값 설정
        }
      } else {
        logger.e("Empty or null payload");
        payload = {}; // 기본값 설정
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: UIhelper.deviceWidth(context) * 0.85,
          height: UIhelper.deviceHeight(context) * 0.67,
          color: Colors.white,
          child: Column(
            children: [
              // 커스텀 헤더
              Container(
                color: const Color(0xFFA292EC),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                child: Container(
                  width: UIhelper.deviceWidth(context) * 0.85,
                  alignment: Alignment.center,
                  child: const Text(
                    '알림함',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      // ListView.builder를 Expanded로 감싸기
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ExpansionTile(
                            title: Text(notification.title),
                            subtitle: Text(notification.createdDate),
                            trailing: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  notification.read
                                      ? Icons.notifications
                                      : Icons.notifications_active,
                                  color: notification.read
                                      ? Colors.grey
                                      : Colors.red,
                                ),
                                if (!notification.read)
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            children: [
                              ListTile(
                                title: const Text('상세 보기'),
                                onTap: () {
                                  _fetchNotificationDetail(
                                      notification.notificationId);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
