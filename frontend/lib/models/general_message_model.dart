import 'dart:io';

class GeneralMessageModel {
  final int? receiverType;
  final String? title;
  final String? content;
  final List<String>? receivers;
  final DateTime? createdAt;
  final File? image;
  final int? groupId;

  GeneralMessageModel({
    this.title,
    this.receiverType,
    this.content,
    this.receivers,
    this.createdAt,
    this.image,
    this.groupId,
  });

  Map<String, dynamic> toJson() => {
        'receiver_type': receiverType,
        'title': title,
        'content': content,
        'receivers': receivers,
        'created_at': createdAt.toString(),
        'image': image,
        'group_id': groupId,
      };
}
