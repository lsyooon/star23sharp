import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioService {
  static String baseUrl = dotenv.env['API_URL'].toString();          

  // Private constructor to prevent instantiation
  DioService._internal();

  // 기본 Dio 인스턴스
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10), // 연결 시간
      receiveTimeout: const Duration(seconds: 10), // 응답 시간
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Authorization 헤더와 인터셉터가 추가된 Dio 인스턴스
  static final Dio authDio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        // 기본 Authorization 헤더 설정 (추후 필요 시 업데이트 가능)
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 전 처리 (예: 토큰 갱신)
          print('Request [${options.method}] ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 후 처리
          print('Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // 에러 처리
          print('Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
}
