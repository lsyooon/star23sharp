import 'package:dio/dio.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';

class NotificationService {
  static const String _notificationEndpoint = '/notification';

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      // API 요청
      final response = await DioService.authDio.get(_notificationEndpoint);
      logger.d(response);
      // 응답 데이터 파싱
      final result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        if (result.data.length > 0) {
          final List<dynamic> notifications = result.data;
          return notifications
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      ErrorHandler.handle(e);
      return [];
    }
  }

  static Future<NotificationDetailModel?> getNotificationDetail(
      int notificationId) async {
    try {
      // API 요청
      final response = await DioService.authDio.get(
        '$_notificationEndpoint/$notificationId',
      );

      // 응답 데이터 파싱
      final result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        return NotificationDetailModel.fromJson(result.data);
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      ErrorHandler.handle(e);
      return null;
    }
  }
}
