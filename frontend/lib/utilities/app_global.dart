import 'package:flutter/material.dart';

class AppGlobal {
  AppGlobal._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
}
