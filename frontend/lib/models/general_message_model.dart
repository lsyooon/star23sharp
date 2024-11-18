import 'dart:io';

class GeneralMessageModel {
  final int? receiverType;
  final String? title;
  final String? content;
  final List<String>? receivers;
  final DateTime? createdAt;
  final File? contentImage;
  final int? groupId;

  GeneralMessageModel({
    this.title,
    this.receiverType,
    this.content,
    this.receivers,
    this.createdAt,
    this.contentImage,
    this.groupId,
  });

  Map<String, dynamic> toJson() => {
        'receiverType': receiverType,
        'title': title,
        'content': content,
        'receivers': receivers,
        'createdAt': createdAt.toString(),
        'contentImage': contentImage,
        'groupId': groupId,
      };
}
