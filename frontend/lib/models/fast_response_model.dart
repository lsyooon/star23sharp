import 'package:star23sharp/models/index.dart';

class FastResponseModel {
  final String code;
  final String? message;
  final List<TreasureModel> data;

  FastResponseModel.fromJson(Map<String, dynamic> json)
      : code = json['code'] ?? 'unknown',
        message = json['message'] ?? '',
        data = (json['data']['treasures'] as List)
            .map((item) => TreasureModel.fromJson(item))
            .toList();
}
