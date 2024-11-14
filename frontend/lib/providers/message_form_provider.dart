import 'dart:io';

import 'package:flutter/material.dart';

import 'package:star23sharp/models/index.dart';

class MessageFormProvider with ChangeNotifier {
  bool _isTeasureStar = false;

  bool get isTeasureStar => _isTeasureStar;

  TreasureMessageModel? _treasureMessage;
  GeneralMessageModel? _generalMessage;

  set isTeasureStar(bool value) {
    _isTeasureStar = value;
  }

  void setMessageFormType({required String type}) {
    if (type == 'hidestar') {
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
      // TreasureMessageModel이 null이 아니면 기존 값을 유지
      _treasureMessage = TreasureMessageModel(
        title: title?.trim() ?? _treasureMessage?.title,
        content: content?.trim() ?? _treasureMessage?.content,
        contentImage: contentImage ?? _treasureMessage?.contentImage,
        receivers: receivers ?? _treasureMessage?.receivers,
        groupId: groupId ?? _treasureMessage?.groupId,
        hint: hint?.trim() ?? _treasureMessage?.hint,
        hintImageFirst: hintImageFirst ?? _treasureMessage?.hintImageFirst,
        hintImageSecond: hintImageSecond ?? _treasureMessage?.hintImageSecond,
        dotHintImage: dotHintImage ?? _treasureMessage?.dotHintImage,
        createdAt: DateTime.now(), // 항상 새로 생성
        receiverType: receiverType ?? _treasureMessage?.receiverType,
        lat: lat ?? _treasureMessage?.lat,
        lng: lng ?? _treasureMessage?.lng,
      );
    } else {
      // GeneralMessageModel이 null이 아니면 기존 값을 유지
      _generalMessage = GeneralMessageModel(
        title: title?.trim() ?? _generalMessage?.title,
        content: content?.trim() ?? _generalMessage?.content,
        receivers: receivers ?? _generalMessage?.receivers,
        groupId: groupId ?? _generalMessage?.groupId,
        createdAt: DateTime.now(), // 항상 새로 생성
        receiverType: receiverType ?? _generalMessage?.receiverType,
        contentImage: contentImage ?? _generalMessage?.contentImage,
      );
    }
    notifyListeners();
  }
}
