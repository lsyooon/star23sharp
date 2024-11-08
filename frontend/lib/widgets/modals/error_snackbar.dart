import 'package:flutter/material.dart';
import 'package:star23sharp/utilities/app_global.dart';

class ErrorSnackbar {
  static void show(String message, {Color backgroundColor = Colors.black54}) {
    final context = AppGlobal.navigatorKey.currentState?.overlay?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
