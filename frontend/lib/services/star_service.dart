import 'dart:io';

import 'package:dio/dio.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';

class StarService {
  // 별 리스트 조회
  static Future<List<StarListItemModel>?> getStarList(bool isSentStar) async {
    List<StarListItemModel> starList = [];
    String type = isSentStar ? "send" : "reception";
    try {
      var response = await DioService.authDio.get('/message/$type/list');

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        if (result.data != null) {
          for (var item in result.data!) {
            starList.add(StarListItemModel.fromJson(item, isSentStar));
          }
          return starList;
        }
      } else {
        throw Exception(result.message);
      }

      return null;
    } on DioException catch (e) {
      logger.e('Failed to fetch star list: $e');
      ErrorHandler.handle(e);
      return null;
    }
  }

  // 수신 별 상세 조회
  static Future<ReceivedStarModel?> getReceivedStar(int messageId) async {
    try {
      var response =
          await DioService.authDio.get('/message/reception/$messageId');

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        if (result.data != null) {
          var data = ReceivedStarModel.fromJson(result.data);
          return data;
        }
      } else {
        throw Exception(result.message);
      }
      return null;
    } on DioException catch (e) {
      logger.e('Failed to fetch received star details: $e');
      ErrorHandler.handle(e);
      return null;
    }
  }

  // 송신 별 상세 조회
  static Future<SentStarModel?> getSentStar(int messageId) async {
    try {
      var response = await DioService.authDio.get('/message/send/$messageId');

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        if (result.data != null) {
          var data = SentStarModel.fromJson(result.data);
          return data;
        }
      } else {
        throw Exception(result.message);
      }
      return null;
    } on DioException catch (e) {
      logger.e('Failed to fetch sent star details: $e');
      ErrorHandler.handle(e);
      return null;
    }
  }

  //별 전송
  static Future<void> sendMessage({
    required bool isTreasureStar,
    required dynamic data, // TreasureMessageModel 또는 GeneralMessageModel
  }) async {
    try {
      // URL 설정
      final url =
          isTreasureStar ? '/fastapi_ec2/treasure/insert' : '/message/common';

      // 데이터 변환 (multipart/form-data)
      final formData = FormData.fromMap(data.toJson());

      // 이미지가 있는 경우 추가
      if (data.contentImage != null && data.contentImage is File) {
        formData.files.add(MapEntry(
          'contentImage',
          await MultipartFile.fromFile(
            data.contentImage.path,
            filename: data.contentImage.path.split('/').last,
          ),
        ));
      }

      // 추가적인 이미지가 있는 경우 처리
      if (isTreasureStar) {
        if (data.hintImageFirst != null && data.hintImageFirst is File) {
          formData.files.add(MapEntry(
            'hintImageFirst',
            await MultipartFile.fromFile(
              data.hintImageFirst.path,
              filename: data.hintImageFirst.path.split('/').last,
            ),
          ));
        }

        if (data.hintImageSecond != null && data.hintImageSecond is File) {
          formData.files.add(MapEntry(
            'hintImageSecond',
            await MultipartFile.fromFile(
              data.hintImageSecond.path,
              filename: data.hintImageSecond.path.split('/').last,
            ),
          ));
        }
      }

      // API 호출
      final response = await DioService.authDio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // 성공 여부 확인
      if (response.statusCode == 200) {
        // 성공 처리
        logger.d("Message sent successfully: ${response.data}");
      } else {
        // 실패 처리
        throw Exception("Failed to send message. Code: ${response.statusCode}");
      }
    } catch (error) {
      // ErrorHandler를 사용하여 에러 처리 및 사용자에게 Snackbar 표시
      ErrorHandler.handle(error);
    }
  }

  static Future<dynamic> getIsUnreadMessage() async {
    try {
      final response = await DioService.authDio.get(
        '/message/unread-state',
      );

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        return result.data;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      logger.d('Failed to create post: $e');
      ErrorHandler.handle(e);
      return false;
    }
  }
}
