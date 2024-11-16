class TreasureModel {
  final int id;
  final int senderId;
  final int receiverType;
  final String? dotHintImage;
  final String title;
  final String hint;
  final double lat;
  final double lng;
  final bool isTreasure;
  final bool isFound;
  final DateTime createdAt;
  final String? image;
  final String? content;
  final String? hintImageFirst;
  final String? senderNickname;

  TreasureModel({
    required this.id,
    required this.senderId,
    required this.receiverType,
    this.dotHintImage,
    required this.title,
    required this.hint,
    required this.lat,
    required this.lng,
    required this.isTreasure,
    required this.isFound,
    required this.createdAt,
    this.image,
    this.content,
    this.hintImageFirst,
    this.senderNickname,
  });

  // JSON 데이터를 모델 객체로 변환하는 팩토리 생성자
  factory TreasureModel.fromJson(Map<String, dynamic> json) {
    return TreasureModel(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverType: json['receiver_type'] ?? 0,
      dotHintImage: json['dot_hint_image'] ?? '',
      title: json['title'] ?? '제목 없음',
      hint: json['hint'] ?? '힌트 없음',
      lat: json['lat'] ?? 0.0,
      lng: json['lng'] ?? 0.0,
      isTreasure: json['is_treasure'] ?? false,
      isFound: json['is_found'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      image: json['image'] ?? '',
      content: json['content'] ?? '',
      hintImageFirst: json['hint_image_first'] ?? '',
      senderNickname: json['sender_nickname'] ?? '',
    );
  }

  // JSON 변환 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_type': receiverType,
      'dot_hint_image': dotHintImage,
      'title': title,
      'hint': hint,
      'lat': lat,
      'lng': lng,
      'is_treasure': isTreasure,
      'is_found': isFound,
      'created_at': createdAt.toString(),
      'image': image,
      'content': content,
      'hintImageFirst': hintImageFirst,
      'senderNickname': senderNickname,
    };
  }
}
