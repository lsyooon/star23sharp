import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';
import 'package:star23sharp/widgets/index.dart';
import 'package:star23sharp/providers/index.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  NotificationSettingsScreenState createState() =>
      NotificationSettingsScreenState();
}

class NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool pushNotificationsEnabled = true; // 기본값
  Map<String, bool> notificationTypes = {
    '내 보물 메세지 발견 시': true,
    '새 메시지 수신 시': true,
  };

  @override
  void initState() {
    super.initState();
    // 초기 상태 설정
    final userProvider = Provider.of<UserProvider>(
        AppGlobal.navigatorKey.currentContext!,
        listen: false);
    pushNotificationsEnabled = userProvider.getPushNotificationEnabled ?? true;
  }

  void _updateNotificationTypes(bool enabled) {
    // 모든 notificationTypes 값을 `enabled`로 설정
    setState(() {
      notificationTypes =
          notificationTypes.map((key, value) => MapEntry(key, enabled));
    });
  }

  void _onPushNotificationToggle(bool value) async {
    try {
      await NotificationService.updateAlarmToggle();
      if (value) {
        logger.d("알림 받기");
        await NotificationService.updateDeviceToken();
      }
      final userProvider = Provider.of<UserProvider>(
          AppGlobal.navigatorKey.currentContext!,
          listen: false);

      setState(() {
        pushNotificationsEnabled = value;
      });
      // Provider를 통해 상태 업데이트
      userProvider.setPushNotificationEnabled(value);

      // notificationTypes 업데이트
      _updateNotificationTypes(value);
    } catch (err) {
      logger.e(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Container(
                  width: UIhelper.deviceWidth(context) * 0.85,
                  alignment: Alignment.center,
                  child: const Text(
                    '알림 설정',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // 푸시 알림 받기 설정
                    SwitchListTile(
                      title: const Text('푸시 알림 받기'),
                      value: pushNotificationsEnabled,
                      onChanged: _onPushNotificationToggle,
                    ),
                    const Divider(),
                    // 개별 알림 설정
                    ...notificationTypes.keys.map((type) {
                      return SwitchListTile(
                        title: Text(type),
                        value: notificationTypes[type]!,
                        onChanged: pushNotificationsEnabled
                            ? (value) {
                                setState(() {
                                  notificationTypes[type] = value;
                                });
                              }
                            : null, // disable 상태로 설정
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
