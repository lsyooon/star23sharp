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
      var response = await DioService.authDio.get('/message/reception/$messageId');
      
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
}
