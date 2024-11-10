import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/widgets/index.dart';

class PushAlarmScreen extends StatefulWidget {
  final int? notificationId; // 푸시 알림에서 전달받은 notificationId

  const PushAlarmScreen({super.key, this.notificationId});
  @override
  State<PushAlarmScreen> createState() => PushAlarmScreenState();
}

class PushAlarmScreenState extends State<PushAlarmScreen> {
  final ScrollController _scrollController = ScrollController();

  List<NotificationModel> notifications = [];
  bool isLoading = true;
  Map<int, bool> expansionStates = {}; // ExpansionTile 상태 관리
  Map<int, NotificationDetailModel?> notificationDetails = {}; // 상세 정보를 저장

  // @override
  // BuildContext context = AppGlobal.navigatorKey.currentState!
  //     .context; // use context from navigator key in app global class

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final fetchedNotifications = await NotificationService.getNotifications();

    setState(() {
      notifications = fetchedNotifications;
      isLoading = false;
      expansionStates = {for (var n in notifications) n.notificationId: false};
    });
    // 알림 ID가 주어졌으면 해당 위치로 스크롤하고 펼치기
    if (widget.notificationId != null) {
      logger.d(widget.notificationId);
      logger.d(widget.notificationId is String);
      final index = notifications
          .indexWhere((n) => n.notificationId == widget.notificationId);
      logger.d("index $index");
      if (index != -1) {
        // 데이터를 모두 설정한 뒤에 알림 확장
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToNotification(widget.notificationId!);
        });
      } else {
        logger.e("Invalid notificationId: ${widget.notificationId}");
      }
    }
  }

  Future<void> _fetchNotificationDetail(int notificationId) async {
    if (!notificationDetails.containsKey(notificationId)) {
      final notificationDetail =
          await NotificationService.getNotificationDetail(notificationId);
      if (notificationDetail != null) {
        setState(() {
          notificationDetails[notificationId] = notificationDetail;
          final index = notifications.indexWhere(
              (notification) => notification.notificationId == notificationId);
          if (index != -1) {
            notifications[index] = notifications[index].copyWith(read: true);
          }
        });
      } else {
        logger.e('알림 상세 정보를 불러오는 데 실패했습니다.');
      }
    }
  }

  void _scrollToNotification(int notificationId) {
    final index =
        notifications.indexWhere((n) => n.notificationId == notificationId);

    if (index != -1) {
      // 스크롤 이동
      _scrollController.animateTo(
        index * 72.0, // 각 항목의 높이를 기준으로 계산 (필요에 따라 조정)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // 해당 ExpansionTile을 펼침
      setState(() {
        expansionStates[notificationId] = true;
      });
    } else {
      logger.e("Notification ID not found in the list.");
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
              Container(
                color: const Color(0xFFA292EC),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                child: Stack(
                  children: [
                    // 제목을 가운데 배치
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        '알림함',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 아이콘을 오른쪽 끝에 배치
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          // 환경설정 페이지로 이동
                          Navigator.pushNamed(context, '/notification_setting');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              final isExpanded = expansionStates[
                                      notification.notificationId] ??
                                  false;
                              return ExpansionTile(
                                title: Text(
                                  notification.title,
                                  maxLines: isExpanded ? null : 1,
                                  overflow: isExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: notification.read
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                    color: notification.read
                                        ? Colors.grey[700]
                                        : Colors.black,
                                  ),
                                ),
                                subtitle: Text(notification.createdDate),
                                onExpansionChanged: (isExpanded) async {
                                  setState(() {
                                    expansionStates[notification
                                        .notificationId] = isExpanded;
                                  });
                                  if (isExpanded) {
                                    await _fetchNotificationDetail(
                                        notification.notificationId);
                                  }
                                },
                                children: [
                                  if (isExpanded)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: notificationDetails[notification
                                                  .notificationId] !=
                                              null
                                          ? _buildNotificationDetail(
                                              notification.notificationId)
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                    ),
                                ],
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 20.0),
                                Text(
                                  "받은 알림이 없어요!",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  "알림은 별을 받았을 때,\n"
                                  "내가 보낸 보물 편지를 찾았을 때 도착해요!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDetail(int notificationId) {
    final detail = notificationDetails[notificationId];
    if (detail == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.content,
          style: const TextStyle(fontSize: 14.0, color: Colors.black),
        ),
        if (detail.hint != null) ...[
          const SizedBox(height: 8),
          Text(
            "${detail.hint}",
            style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
          ),
        ],
        if (detail.image != null) ...[
          const SizedBox(height: 8),
          Image.network(detail.image!),
        ],
      ],
    );
  }
}
