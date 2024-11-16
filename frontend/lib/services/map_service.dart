import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';

import 'package:star23sharp/main.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';
import 'package:star23sharp/utilities/index.dart';

class MapService {
  // 마커 정보 가져오기
  static Future<List<dynamic>?> getTreasures(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
    bool includeOpend,
    bool getReceived,
    bool includedPublic,
    bool includeGroup,
    bool includePrivate,
  ) async {
    try {
      final response = await DioService.fastAuthDio.get(
        '/fastapi_ec2/treasure/near',
        queryParameters: {
          'lat_1': lat1,
          'lng_1': lng1,
          'lat_2': lat2,
          'lng_2': lng2,
          'include_opend': includeOpend,
          'get_received': getReceived,
          'include_public': includedPublic,
          'include_group': includeGroup,
          'include_private': includePrivate,
        },
      );

      var result = FastResponseModel.fromJson(response.data);
      if (result.code == '200') {
        return result.data as List<dynamic>;
      } else {
        return null;
      }
    } on DioException catch (e) {
      logger.d('Failed to fetch markers: $e');
      ErrorHandler.handle(e);
      return null;
    }
  }

  // 마커 상세 정보 가져오기
  static Future<List<dynamic>?> getTreasureDetail(int id) async {
    try {
      final response = await DioService.fastAuthDio.get(
        '/fastapi_ec2/treasure/inspect',
        queryParameters: {
          'ids': id,
        },
      );

      var result = FastResponseModel.fromJson(response.data);
      if (result.code == '200') {
        return result.data as List<dynamic>;
      } else {
        return null;
      }
    } on DioException catch (e) {
      logger.d('Failed to fetch markers: $e');
      ErrorHandler.handle(e);
      return null;
    }
  }

  // 픽셀화 이미지 API 호출
  static Future<Uint8List?> pixelizeImage({
    required File file,
    required int kernelSize,
    required int pixelSize,
  }) async {
    try {
      final formData = FormData.fromMap({
        // 'file': await MultipartFile.fromFile(file.path,
        //     filename: file.path.split('/').last),
        'kernel_size': kernelSize,
        'pixel_size': pixelSize,
      });

      final compressedFile = await compressImage(file);
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          compressedFile.path,
          filename: path.basename(compressedFile.path),
          contentType: MediaType.parse(
              'multipart/form-data'), // Content-Type: multipart/form-data
        ),
      ));
      logger.d("파일 이미지 압축 및 추가 완료");

      final response = await DioService.fastAuthDio.post(
        '/fastapi_ec2/image/pixelize',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        logger.d("API 응답 오류: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      logger.d("API 호출 실패: $e");
      ErrorHandler.handle(e);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> verifyPhoto({
    required File file,
    required int id,
    required double lat,
    required double lng,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'id': id,
        'lat': lat,
        'lng': lng,
      });

      final response = await DioService.fastAuthDio.post(
        '/fastapi_ec2/treasure/authorize',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final responseData = jsonDecode(response.toString());
      logger.d(responseData);
      return responseData;
    } on DioException catch (e) {
      logger.d("API 호출 실패: $e");
      ErrorHandler.handle(e);
      return null;
    }
  }
}
