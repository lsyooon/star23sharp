import 'package:flutter/material.dart';
import 'package:star23sharp/utilities/app_global.dart';

class SnackbarRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _clearSnackBarsOnNavigation();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _clearSnackBarsOnNavigation();
  }

  void _clearSnackBarsOnNavigation() {
    final context = AppGlobal.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars(); // 화면 전환 시 모든 스낵바 제거
    }
  }
}
