class NotificationModel {
  final int notificationId;
  final String title;
  final String createdDate;
  final bool read;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.createdDate,
    required this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],
      title: json['title'],
      createdDate: json['createdDate'],
      read: json['read'],
    );
  }
}

extension NotificationModelExtension on NotificationModel {
  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      notificationId: notificationId,
      title: title,
      createdDate: createdDate,
      read: read ?? this.read,
    );
  }
}

class NotificationDetailModel {
  final int notificationId;
  final String title;
  final String content;
  final String? hint; // 보물 쪽지 위치 힌트
  final String? image; // 힌트 이미지
  final String createdDate;

  NotificationDetailModel({
    required this.notificationId,
    required this.title,
    required this.content,
    this.hint,
    this.image,
    required this.createdDate,
  });

  // JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory NotificationDetailModel.fromJson(Map<String, dynamic> json) {
    return NotificationDetailModel(
      notificationId: json['notificationId'],
      title: json['title'],
      content: json['content'],
      hint: json['hint'],
      image: json['image'],
      createdDate: json['createdDate'],
    );
  }
}
