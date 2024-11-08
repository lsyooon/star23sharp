import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool pushNotificationsEnabled = true;
  Map<String, bool> notificationTypes = {
    '공지사항': true,
    '새 메시지': true,
    '새 댓글': true,
    '추천 글/정보': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('푸시 알림 받기'),
            value: pushNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                pushNotificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          ...notificationTypes.keys.map((type) {
            return SwitchListTile(
              title: Text(type),
              value: notificationTypes[type]!,
              onChanged: (value) {
                setState(() {
                  notificationTypes[type] = value;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
