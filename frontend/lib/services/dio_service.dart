import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:star23sharp/main.dart';
import 'package:star23sharp/providers/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/app_global.dart';

class DioService {
  static String baseUrl = dotenv.env['API_URL'].toString();
  static String fastBaseUrl = dotenv.env['FAST_API_URL'].toString();

  // Private constructor to prevent instantiation
  DioService._internal();

  // 기본 Dio 인스턴스
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
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
        'Authorization': 'Bearer',
      },
    ),
  )..interceptors.add(createAuthInterceptor(authDio));

  // Authorization 헤더와 인터셉터가 추가된 Dio 인스턴스
  static final Dio fastAuthDio = Dio(
    BaseOptions(
      baseUrl: fastBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer',
      },
    ),
  )..interceptors.add(createAuthInterceptor(fastAuthDio));

  // Authorization 토큰을 업데이트하는 메서드
  static void updateAuthorizationHeader(String token) {
    logger.d(token);
    authDio.options.headers['Authorization'] = 'Bearer $token';
    fastAuthDio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 공통 인터셉터 생성 함수
  static InterceptorsWrapper createAuthInterceptor(Dio dioInstance) {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        logger.d('Error: ${e.message}');

        if (e.response?.statusCode == 401) {
          final authProvider = Provider.of<AuthProvider>(
            AppGlobal.navigatorKey.currentContext!,
            listen: false,
          );

          final newToken = await authProvider.refreshTokens();
          if (newToken != null) {
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            if (e.requestOptions.data is FormData) {
              final originalData = e.requestOptions.data as FormData;

              final newFormData = FormData();
              newFormData.fields.addAll(originalData.fields);

              for (var fileEntry in originalData.files) {
                newFormData.files.add(MapEntry(
                  fileEntry.key,
                  fileEntry.value.clone(),
                ));
              }
              e.requestOptions.data = newFormData;
            }

            final cloneReq = await dioInstance.fetch(e.requestOptions);
            return handler.resolve(cloneReq);
          } else {
            Navigator.pushNamed(AppGlobal.navigatorKey.currentContext!, '/signin');
          }
        } else {
          try {
            final failure = ErrorHandler.handle(e).failure;
            logger.e('Error [${failure.code}]: ${failure.message}');
            handler.reject(e);
          } catch (error) {
            logger.e('Unhandled Error: $error');
            handler.reject(e);
          }
        }

        return handler.next(e);
      },
    );
  }
}
