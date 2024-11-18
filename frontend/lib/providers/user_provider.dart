import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? memberId;
  String? nickname;
  bool? isPushNotificationEnabled = true;

  // memberId 조회
  String? get getMemberId => memberId;

  // nickname 조회
  String? get getNickname => nickname;

  // PushNotificationEnabled 조회
  bool? get getPushNotificationEnabled => isPushNotificationEnabled;

  void setPushNotificationEnabled(bool isEnabled) {
    isPushNotificationEnabled = isEnabled;
  }

  // 여러 변수 한번에 설정
  void setUserDetails({
    String? id,
    String? name,
    bool? isPushEnabled,
  }) {
    memberId = id;
    nickname = name;
    isPushNotificationEnabled = isPushEnabled;
    notifyListeners(); // 값이 변경되면 리스너에 알림
  }
}
