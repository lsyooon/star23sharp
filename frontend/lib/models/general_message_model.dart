import 'dart:io';

class GeneralMessageModel {
  final int receiverType;
  final String title;
  final String content;
  final List<String> recipients;
  final DateTime createdAt;
  final File? image;
  final int? groupId;

  GeneralMessageModel({
    required this.receiverType,
    required this.title,
    required this.content,
    required this.recipients,
    required this.createdAt,
    this.image,
    this.groupId,
  });

  Map<String, dynamic> toJson() => {
        'receiver_type': receiverType,
        'title': title,
        'content': content,
        'recipients': recipients,
        'created_at': createdAt.toIso8601String(),
        'image': image,
        'group_id': groupId,
      };
}
