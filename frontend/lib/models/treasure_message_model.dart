import 'dart:io';

class TreasureMessageModel {
  final int? receiverType;
  final String? title;
  final String? content;
  final File? contentImage;
  final List<String>? receivers;
  final int? groupId;
  final String? hint;
  final File? hintImageFirst;
  final File? hintImageSecond;
  final File? dotHintImage;
  final int? dotTarget;
  final int? kernelSize;
  final int? pixelSize;
  final DateTime? createdAt;
  final double? lat;
  final double? lng;

  TreasureMessageModel({
    this.title,
    this.content,
    this.contentImage,
    this.receivers,
    this.groupId,
    this.hint,
    this.hintImageFirst,
    this.hintImageSecond,
    this.dotHintImage,
    this.dotTarget,
    this.kernelSize,
    this.pixelSize,
    this.createdAt,
    this.lat,
    this.lng,
    this.receiverType,
  });

  Map<String, dynamic> toJson() => {
        'receiverType': receiverType,
        'title': title,
        'content': content,
        'receivers': receivers,
        'createdAt': createdAt.toString(),
        'contentImage': contentImage,
        'groupId': groupId,
        'hint': hint,
        'hint_image_first': hintImageFirst,
        'hint_image_second': hintImageSecond,
        'dot_hint_image': dotHintImage,
        // 'dot_target': dotTarget,
        // 'kernel_size': kernelSize,
        // 'pixel_size': pixelSize,
        'lat': lat,
        'lng': lng,
      };
}
