import 'package:flutter/material.dart';
import 'package:star23sharp/utilities/app_global.dart';

class ErrorSnackbar {
  static void show(String message, {Color backgroundColor = Colors.black54, Color textColor = Colors.red}) {
    final context = AppGlobal.navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: textColor),
          ),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
