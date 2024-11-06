import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  
  void logIn(String accessToken, String refreshToken) {
    _isLoggedIn = true;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners(); // 해당 provider를 참조하는 모든 위젯에 정보를 뿌림
  }

  void logOut() {
    _isLoggedIn = false;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  void saveTokens(String accessToken, String refreshToken) {
    // 로그인, 액세스 토큰 재발급 시 -> refresh 토큰도 갱신
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}
