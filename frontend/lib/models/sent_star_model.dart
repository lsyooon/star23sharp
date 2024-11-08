class SentStarModel {
  final String title, createdAt, content;
  final String? image, recipient;
  final List<String> receiverNames; // JSON에서 senderNickname에 해당하는 필드
  final int messageId, receiverType;
  final bool kind, state;

  // receiverType -> 0: 개인, 1: 단체(그룹 미지정), 2: 단체(그룹 지정), 3: 불특정 다수
  // kind -> true: 보물쪽지 / false : 일반 쪽지
  SentStarModel.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        title = json['title'],
        receiverNames = List<String>.from(json['receiverNames']), // List<String>으로 변환
        receiverType = json['receiverType'],
        createdAt = json['createdDate'],
        content = json['content'],
        image = json['image'],
        recipient = json['recipient'],
        kind = json['kind'],
        state = json['state'];
}
