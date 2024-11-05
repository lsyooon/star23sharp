import 'dart:convert';

import 'package:star23sharp/models/received_star_model.dart';
import 'package:dio/dio.dart';

class StarApiService {
    static const baseUrl = "env에서 가져오기";
    static Dio dio = Dio();

    // 수신 별 받아오는 API
    static Future<List<ReceivedStarModel>> getReceivedStarList() async{
      List<ReceivedStarModel> starList = [];
      var response = await dio.get(baseUrl);
      if(response.statusCode == 200){
        final List<dynamic> list = jsonDecode(response.data);
      for (var item in list) {
        starList.add(ReceivedStarModel.fromJson(item));
      }
      return starList;
      }
      
      throw Error();
    }
}
