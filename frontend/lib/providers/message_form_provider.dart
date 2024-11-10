import 'dart:io';

import 'package:flutter/material.dart';

import 'package:star23sharp/models/index.dart';

class MessageFormProvider with ChangeNotifier {
  bool _isTeasureStar = true;

  bool get isTeasureStar => _isTeasureStar;

  TreasureMessageModel? _treasureMessage;
  GeneralMessageModel? _generalMessage;

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

  void updateHint(String newHint) {
    if (_isTeasureStar && _treasureMessage != null) {
      _treasureMessage = _treasureMessage!.copyWith(hint: newHint);
      notifyListeners();
    }
  }

  // Getter to retrieve content of the current message based on the type
  String? get content =>
      _isTeasureStar ? _treasureMessage?.content : _generalMessage?.content;

  // Getter for title
  String? get title =>
      _isTeasureStar ? _treasureMessage?.title : _generalMessage?.title;

  // Getter for recipients (or receivers)
  List<String>? get recipients =>
      _isTeasureStar ? _treasureMessage?.receivers : _generalMessage?.receivers;

  // 전체 메시지 데이터를 반환하는 getter
  dynamic get messageData =>
      _isTeasureStar ? _treasureMessage : _generalMessage;

// 모델 저장 메서드
  void saveMessageData({
    String? title,
    String? content,
    File? contentImage,
    List<String>? receivers,
    int? groupId,
    String? hint,
    File? hintImageFirst,
    File? hintImageSecond,
    File? dotHintImage,
    int? dotTarget,
    int? kernelSize,
    int? pixelSize,
    double? lat,
    double? lng,
    File? image,
    int? receiverType,
  }) {
    if (_isTeasureStar) {
      // TreasureMessageModel 생성 및 저장
      _treasureMessage = TreasureMessageModel(
        title: title,
        content: content,
        contentImage: contentImage,
        receivers: receivers,
        groupId: groupId,
        hint: hint,
        hintImageFirst: hintImageFirst,
        hintImageSecond: hintImageSecond,
        dotHintImage: dotHintImage,
        // dotTarget: dotTarget,
        // kernelSize: kernelSize,
        // pixelSize: pixelSize,
        createdAt: DateTime.now(),
        lat: lat,
        lng: lng,
        receiverType: receiverType,
      );
    } else {
      // GeneralMessageModel 생성 및 저장
      _generalMessage = GeneralMessageModel(
        receiverType: receiverType,
        title: title,
        content: content,
        receivers: receivers ?? [],
        createdAt: DateTime.now(),
        contentImage: contentImage,
        groupId: groupId,
      );
    }
    notifyListeners();
  }
}
