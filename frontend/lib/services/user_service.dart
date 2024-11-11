import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';

class UserService {
  // 아이디 및 닉네임 중복 확인
  static Future<bool> checkDuplicateId(int checkType, String value) async {
    // checkType -> 0: ID, 1: 닉네임
    try {
      final response = await DioService.dio.post(
        '/member/duplicate',
        data: {
          'checkType': checkType,
          'value': value,
        },
      );

      var result = ResponseModel.fromJson(response.data);
      logger.d(result.data);
      if (result.code == '200') {
        return result.data;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      ErrorHandler.handle(e); // 에러 처리 및 Snackbar 표시
      return true;
    } catch (e) {
      logger.e('Unexpected error: $e');
      return true;
    }
  }

  // 회원가입
  static Future<bool> signup(
      String memberId, String password, String nickname) async {
    // checkType -> 0: ID, 1: 닉네임
    try {
      final response = await DioService.dio.post(
        '/member/join',
        data: {
          'memberId': memberId,
          'password': password,
          'nickname': nickname,
        },
      );

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        return true;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      ErrorHandler.handle(e); // 에러 처리 및 Snackbar 표시
      return false; // 에러 발생 시 false 반환
    } catch (e) {
      logger.e('Unexpected error: $e');
      return false; // 기타 예외 발생 시 false 반환
    }
  }

  // 로그인
  static Future<Map<String, String>?> login(
      String memberId, String password) async {
    try {
      final response = await DioService.dio.post(
        '/login',
        data: {
          'memberId': memberId,
          'password': password,
        },
      );

      var result = ResponseModel.fromJson(response.data);
      logger.d(result);
      if (result.code == '200') {
        String access = response.headers['access']?.first ?? '';
        String refresh = response.headers['refresh']?.first ?? '';
        return {'access': access, 'refresh': refresh};
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      ErrorHandler.handle(e); // 에러 처리 및 Snackbar 표시
      return null;
    }
  }

  // 로그아웃
  static Future<bool> logout(String refresh) async {
    try {
      logger.d(refresh);
      final response = await DioService.dio.post(
        '/logout',
        options: Options(
          headers: {
            'refresh': refresh,
          },
        ),
      );

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      return false;
    }
  }

  // 토큰 갱신
  static Future<Map<String, String>?> refreshToken(String refresh) async {
    try {
      final response = await DioService.dio.post(
        '/refresh',
        options: Options(
          headers: {
            'refresh': refresh,
          },
        ),
      );
      logger.d(response.requestOptions.headers);

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        String access = response.headers['access']?.first ?? '';
        String refresh = response.headers['refresh']?.first ?? '';
        return {'access': access, 'refresh': refresh};
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      ErrorHandler.handle(e); // 에러 처리 및 Snackbar 표시
    }
    return null;
  }

  // JWT 토큰에서 exp (만료 시간) 추출하는 함수
  static int? getExpirationTime(String token) {
    // JWT를 '.' 기준으로 분리
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null; // 잘못된 토큰 형식
    }

    // JWT의 두 번째 부분(payload)을 디코딩
    String payload = parts[1];
    String decodedPayload =
        utf8.decode(base64Url.decode(base64Url.normalize(payload)));

    // payload를 JSON으로 변환하여 'exp' 필드 추출
    Map<String, dynamic> payloadMap = jsonDecode(decodedPayload);
    return payloadMap['exp']; // Unix timestamp로 반환
  }

// 남은 시간을 계산하는 함수
  static String getTimeRemaining(String token) {
    int? exp = getExpirationTime(token);
    if (exp == null) {
      return 'Invalid token';
    }

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int remainingTime = exp - currentTime;

    if (remainingTime <= 0) {
      return 'Token has expired';
    }

    int hours = remainingTime ~/ 3600;
    int minutes = (remainingTime % 3600) ~/ 60;
    int seconds = remainingTime % 60;

    return '$hours hours, $minutes minutes, $seconds seconds remaining';
  }

  // 회원 정보 조회
  static Future<dynamic> getMemberInfo() async {
    try {
      logger.d('회원 조회 시 헤더! : ${DioService.authDio.options.headers}');
      logger.d(getTimeRemaining(DioService.authDio.options.headers['Authorization']));
      final response = await DioService.authDio.get(
        '/member/info',
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
    }
  }
}
