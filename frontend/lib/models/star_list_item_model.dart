class StarListItemModel {
  final String title, senderNickname, createdDate;
  final int messageId, receiverType;
  final bool kind, state, isSent;

  // receiverType -> 0: 개인, 1: 단체, 2: 불특정 다수
  // kind -> true: 보물쪽지 / false : 일반 쪽지
  // state: true이면 읽은 거!
  StarListItemModel.fromJson(Map<String, dynamic> json, bool isSentStar)
      : messageId = json['messageId'],
        title = json['title'],
        senderNickname = isSentStar ? json['recipient'] : json['senderNickname'],
        receiverType = json['receiverType'],
        createdDate = json['createdDate'],
        kind = json['kind'],
        state = json['state'],
        isSent = isSentStar;
}
