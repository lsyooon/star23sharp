import 'package:flutter/material.dart';

enum AppTheme { black, blue, red }

class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.black;

  AppTheme get currentTheme => _currentTheme;

  // 테마에 따른 backgroundColor와 backgroundImage 설정
  Color get backgroundColor {
    switch (_currentTheme) {
      case AppTheme.blue:
        return Colors.blue[900]!;
      case AppTheme.red:
        return Colors.red[900]!;
      case AppTheme.black:
      default:
        return const Color(0xff444444);
    }
  }

  String get backgroundImage {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/blue_background.jpg';
      case AppTheme.red:
        return 'assets/red_background.jpg';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/black_bg.png';
    }
  }

  String get bottomNavigationImage {
    switch (_currentTheme) {
      case AppTheme.blue:
        return 'assets/blue_background.jpg';
      case AppTheme.red:
        return 'assets/red_background.jpg';
      case AppTheme.black:
      default:
        return 'assets/img/blackTheme/black_button_container.png';
    }
  }

  // 테마 전환 메서드
  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}
