import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/services/index.dart';

class StarService {
  
  // 수신 별 리스트 조회
  static Future<List<ReceivedStarListModel>?> getReceivedStarList() async{
    List<ReceivedStarListModel> starList = [];

    var response = await DioService.authDio.get(
      '/message/reception/list'
    );

    var result = ResponseModel.fromJson(response.data);
    if(result.code == '200'){
      if(result.data != null){
        for (var item in result.data!) {
          starList.add(ReceivedStarListModel.fromJson(item));
        }
        return starList;
      }
    }
    
    return null;
  }

  // 수신 별 상세조회
  static Future<ReceivedStarModel?> getReceivedStar(int messageId) async{
    var response = await DioService.authDio.get(
      '/message/reception/$messageId'
    );

    var result = ResponseModel.fromJson(response.data);
    if(result.code == '200'){
      if(result.data != null){
        var data = ReceivedStarModel.fromJson(result.data);
        return data;
      }
    }
    return null;
  }

  // 송신 별 리스트 조회

  // 송신 별 상세조회
}
