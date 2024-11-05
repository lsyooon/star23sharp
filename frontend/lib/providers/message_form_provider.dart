import 'package:flutter/material.dart';

class MessageFormProvider with ChangeNotifier {
  List<String> recipients = [];
  String title = '';
  String message = '';
  String hintText = '';
  String hintImg = '';
  bool _isTeasureStar = false;

  bool get isTeasureStar => _isTeasureStar;

  set isTeasureStar(bool value) {
    _isTeasureStar = value;
  }

  void setMessageFormType({required String type}) {
    if (type == '/map') {
      isTeasureStar = true;
    } else {
      isTeasureStar = false;
    }
    notifyListeners();
  }

  // 힌트 데이터를 저장하는 함수
  void saveHintData({required String text, required String img}) {
    hintText = text;
    hintImg = img;
    notifyListeners();
  }

  // 일반 데이터를 저장하는 함수
  void saveMessageData({
    required String newTitle,
    required String newMessage,
    required List<String> newRecipients,
  }) {
    title = newTitle;
    message = newMessage;
    recipients = newRecipients;
    notifyListeners();
  }

  void clearFormData() {
    title = '';
    message = '';
    recipients.clear();
    hintText = '';
    hintImg = '';
    notifyListeners();
  }
}
