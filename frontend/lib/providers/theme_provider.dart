import 'package:flutter/material.dart';
import 'package:star23sharp/main.dart';

enum AppTheme { black, blue, red }

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.black;

  AppTheme get currentTheme => _currentTheme;

  // 테마에 따른 backgroundColor와 backgroundImage 설정
  Color get backgroundColor {
    switch (_currentTheme) {
      case AppTheme.blue:
        return const Color(0xffBEDBFA);
      case AppTheme.red:
        return const Color(0xffFFA081);
      case AppTheme.black:
      default:
        return const Color(0xff444444);
    }
  }

  String get backgroundImage {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/blue_bg.png';
      case AppTheme.red:
        return 'assets/img/redTheme/red_bg.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/black_bg.png';
    }
  }

  String get bottomNavigationImage {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/blue_button_container.png';
      case AppTheme.red:
        return 'assets/img/redTheme/red_button_container.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/black_button_container.png';
    }
  }

  String get sideButtonContainer {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/blue_button_circle.png';
      case AppTheme.red:
        return 'assets/img/redTheme/red_button_circle.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/black_button_circle.png';
    }
  }

  String get centerButton {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/blue_center_button.png';
      case AppTheme.red:
        return 'assets/img/redTheme/red_center_button.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/black_center_button.png';
    }
  }

  Color get mainColor {
    switch (_currentTheme) {
      case AppTheme.blue:
        return const Color(0xFF69ABF4);
      case AppTheme.red:
        return const Color(0xFFD67772);
      case AppTheme.black:
      default:
        return const Color(0xFFA292EC);
    }
  }

  String get mainBg {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/bg_main.png';
      case AppTheme.red:
        return 'assets/img/redTheme/bg_main.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/bg_main.png';
    }
  }

  String get subBg {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/bg_sub.png';
      case AppTheme.red:
        return 'assets/img/redTheme/bg_sub.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/bg_sub.png';
    }
  }

  String get mail {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/mail.png';
      case AppTheme.red:
        return 'assets/img/redTheme/mail.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/mail.png';
    }
  }

  String get profile {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/profile.png';
      case AppTheme.red:
        return 'assets/img/redTheme/profile.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/profile.png';
    }
  }

  String get bell {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/bell.png';
      case AppTheme.red:
        return 'assets/img/redTheme/bell.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/bell.png';
    }
  }

  String get back {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/img/blueTheme/back.png';
      case AppTheme.red:
        return 'assets/img/redTheme/back.png';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/back.png';
    }
  }

  // 테마 전환 메서드
  void setTheme(AppTheme theme) {
    logger.d(theme);
    _currentTheme = theme;
    storage.write(key: 'theme', value: theme.toString());
    notifyListeners();
  }
}
