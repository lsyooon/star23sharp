class ReceivedStarModel {
  final String title, senderNickname, createdDate;
  final int messageId, receiverType;
  final bool kind;

  ReceivedStarModel.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        title = json['title'],
        senderNickname = json['senderNickname'],
        receiverType = json['receiverType'],
        createdDate = json['createdDate'],
        kind = json['kind'];
}
