class ReceivedStarModel {
  final String title, senderNickname, createdDate;
  final int messageId, receiverType;
  final bool kind;

  // receiverType -> 0: 개인, 1: 단체, 2: 불특정 다수
  // kind -> true: 보물쪽지 / false : 일반 쪽지
  ReceivedStarModel.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        title = json['title'],
        senderNickname = json['senderNickname'],
        receiverType = json['receiverType'],
        createdDate = json['createdDate'],
        kind = json['kind'];
}
