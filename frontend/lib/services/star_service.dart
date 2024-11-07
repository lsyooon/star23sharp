import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:star23sharp/models/index.dart';
import 'package:dio/dio.dart';

class StarService {
  static Dio dio = Dio();
  static String baseUrl = dotenv.env['API_URL'].toString();

  // 수신 별 받아오는 API
  static Future<List<ReceivedStarModel>> getReceivedStarList() async {
    List<ReceivedStarModel> starList = [];
    var response = await dio.get(baseUrl);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.data);
      for (var item in list) {
        starList.add(ReceivedStarModel.fromJson(item));
      }
      return starList;
    }

    throw Error();
  }
}
