import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';

class StarService {
  // 별 리스트 조회
  static Future<List<StarListItemModel>?> getStarList(bool isSentStar, int type) async {
    List<StarListItemModel> starList = [];
    String isSent = isSentStar ? "send" : "reception";
    // type -> 0: 전체, 1: 보물, 2: 일반
    try {
      var response = await DioService.authDio.get('/message/$isSent/list/$type');

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
      logger.d(result.data);
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

  static Future<bool> sendMessage({
    required bool isTreasureStar,
    required dynamic data,
  }) async {
    try {
      final url =
          isTreasureStar ? '/fastapi_ec2/treasure/insert' : '/message/common';

      final Map<String, dynamic> rawData = data.toJson();
      // 빈 문자열을 null로 변환
      final Map<String, dynamic> processedData = {};
      rawData.forEach((key, value) {
        if (value != null &&
            !((value is String && value.isEmpty) ||
                (value is List && value.isEmpty) ||
                (value is File))) {
          processedData[key] = value;
        }
      });
      processedData['createdAt'] = DateTime.now().toIso8601String();

      var formData = FormData();
      var dio = Dio();
      if (isTreasureStar) {
        dio = DioService.fastAuthDio;
        formData = FormData.fromMap(processedData);
      } else {
        dio = DioService.authDio;
        logger.d("일바편지@");
        formData = FormData.fromMap({
          'request': MultipartFile.fromString(
            jsonEncode(processedData),
            contentType: MediaType.parse('application/json'),
          )
        });
      }

      logger.d("data : ${data.toJson()}");
      logger.d("폼데이터 초기: ${formData.fields}");

      // 파일 처리
      Future<void> addCompressedImage(String fieldName, File? file) async {
        if (file != null) {
          final compressedFile = await compressImage(file);
          formData.files.add(MapEntry(
            fieldName,
            await MultipartFile.fromFile(
              compressedFile.path,
              filename: path.basename(compressedFile.path),
              contentType: MediaType.parse(
                  'multipart/form-data'), // Content-Type: multipart/form-data
            ),
          ));
          logger.d("$fieldName 이미지 압축 및 추가 완료");
        }
      }

      // contentImage 처리
      if (data.contentImage != null && data.contentImage is File) {
        await addCompressedImage('contentImage', data.contentImage);
      }
      if (isTreasureStar) {
        logger.d("Treasure 이미지 추가 전 FormData: ${formData.fields}");
        await addCompressedImage('hint_image_first', data.hintImageFirst);
        await addCompressedImage('hint_image_second', data.hintImageSecond);
        await addCompressedImage('dot_hint_image', data.dotHintImage);
      }
      logger.d("API 호출 직전 FormData: ${formData.fields} / ${formData.files}");

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      logger.d("API 호출 완료: $response");
      var result = ResponseModel.fromJson(response.data);
      logger.d(result);
      if (result.code == '200') {
        logger.d("Message sent successfully: ${result.data}");
        return true;
      } else {
        throw Exception("Failed to send message. Code: ${result.message}");
      }
      // return true;
    } on DioException catch (e) {
      logger.e('요청 실패: ${e.response?.data ?? e.message}');
      ErrorHandler.handle(e);
      return false;
    } catch (error, stackTrace) {
      logger.e("ErrorHandler 처리 중 문제 발생: $error, $stackTrace");
      return false;
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
