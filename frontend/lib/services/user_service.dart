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
      if (result.code == '200') {
        if (result.data) {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    } on DioException catch (e) {
      logger.d('Failed to create post: $e');
      throw Exception('Failed to create post');
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
        return false;
      }
    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      throw Exception('Failed to create post');
    }
  }

  // 로그인
  static Future<Map<String, String>?> login(
      String memberId, String password) async {
    // checkType -> 0: ID, 1: 닉네임
    try {
      final response = await DioService.dio.post(
        '/login',
        data: {
          'memberId': memberId,
          'password': password,
        },
      );

      var result = ResponseModel.fromJson(response.data);
      if (result.code == '200') {
        String access = response.headers['access'].toString();
        String refresh = response.headers['refresh'].toString();

        // 로그인
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
}
