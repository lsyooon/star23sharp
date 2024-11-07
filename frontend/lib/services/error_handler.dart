import 'package:dio/dio.dart';

import 'package:star23sharp/constant/index.dart';
import 'package:star23sharp/utilities/enums/index.dart';
import 'package:star23sharp/models/index.dart';
import 'package:star23sharp/widgets/modals/error_snackbar.dart';

class ErrorHandler implements Exception {
  late ResponseModel failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      failure = _handleDioError(error);
    } else {
      failure = ResponseCode.unhandledException.getFailure();
    }
    ErrorSnackbar.show(failure.message);
  }

  ResponseModel _handleDioError(DioException error) {
    final errorCode = error.response?.data['code'] as String?;
    if (errorCode != null) {
      return errorCode.getFailure();
    } else {
      return ResponseCode.unhandledException.getFailure();
    }
  }
}
