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

  TreasureMessageModel copyWith({
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
    DateTime? createdAt,
    double? lat,
    double? lng,
    File? image,
  }) {
    return TreasureMessageModel(
      title: title ?? this.title,
      content: content ?? this.content,
      contentImage: contentImage ?? this.contentImage,
      receivers: receivers ?? this.receivers,
      groupId: groupId ?? this.groupId,
      hint: hint ?? this.hint,
      hintImageFirst: hintImageFirst ?? this.hintImageFirst,
      hintImageSecond: hintImageSecond ?? this.hintImageSecond,
      dotHintImage: dotHintImage ?? this.dotHintImage,
      dotTarget: dotTarget ?? this.dotTarget,
      kernelSize: kernelSize ?? this.kernelSize,
      pixelSize: pixelSize ?? this.pixelSize,
      createdAt: createdAt ?? this.createdAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      image: image ?? this.image,
    );
  }

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
