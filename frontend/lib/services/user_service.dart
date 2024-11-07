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
      if(result.code == '200'){
        return false;
      } else {
        return true;
      }

    } on DioException catch (e) {
      logger.d('Failed to create post: $e');
      return true;
    }
  }

  // 회원가입
  static Future<bool> signup(String memberId, String password, String nickname) async {
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
      if(result.code == '200'){
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
  static Future<Map<String, String>?> login(String memberId, String password) async {
    try {
      final response = await DioService.dio.post(
        '/login',
        data: {
          'memberId': memberId,
          'password': password,
        },
      );

      var result = ResponseModel.fromJson(response.data);
      if(result.code == '200'){
        String access = response.headers['access']?.first ?? '';
        String refresh = response.headers['refresh']?.first ?? '';
        return {'access': access, 'refresh': refresh};
      } else {
        return null;
      }

    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
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
      if(result.code == '200'){
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
      logger.d(refresh);
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
      if(result.code == '200'){
        String access = response.headers['access']?.first ?? '';
        String refresh = response.headers['refresh']?.first ?? '';
        return {'access': access, 'refresh': refresh};
      } else {
        return null;
      }

    } on DioException catch (e) {
      logger.e('Failed to create post: $e');
      return null;
    }
  }

  // 회원 정보 조회
  static Future<dynamic> getMemberInfo() async {
    try {
      logger.d(DioService.authDio.options);
      final response = await DioService.authDio.get(
        '/member/info',
      );

      var result = ResponseModel.fromJson(response.data);
      if(result.code == '200'){
        return result.data;
      } else {
        return null;
      }

    } on DioException catch (e) {
      logger.d('Failed to create post: $e');
      return null;
    }
  }

}
