class ReceivedStarModel {
  final String title, createdAt, content;
  final String? image;
  final List<String> senderName; 
  final int messageId, receiverType;
  final bool kind, reported;

  // receiverType -> 0: 개인, 1: 단체(그룹 미지정), 2: 단체(그룹 지정), 3: 불특정 다수
  // kind -> true: 보물쪽지 / false : 일반 쪽지
  ReceivedStarModel.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        title = json['title'],
        senderName = List<String>.from(json['senderNickname']), // List<String>으로 변환
        receiverType = json['receiverType'],
        createdAt = json['createdAt'],
        content = json['content'],
        image = json['image'],
        kind = json['kind'],
        reported = json['reported'];
}
