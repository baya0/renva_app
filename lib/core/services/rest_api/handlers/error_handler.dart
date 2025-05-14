import 'package:dio/dio.dart';

import '../constants/messages.dart';
import '../constants/api_error.dart';
import '../models/response_model.dart';

///General error handler for all requests
ResponseModel mainErrorHandler(DioException error) {
  switch (error.type) {
    case DioExceptionType.badResponse:
      switch (error.response!.statusCode) {
        case 400:
          return ResponseModel(
            success: false,
            statusCode: 400,
            message:
                error.response?.data?['message'] ?? APIErrorMessages.badRequest,
            errorType: BAD_REQUEST(),
          );
        case 401:
          return ResponseModel(
            success: false,
            statusCode: 401,
            message: APIErrorMessages.noAuth,
            errorType: UN_AUTHORIZED(),
          );
        case 403:
          return ResponseModel(
            success: false,
            statusCode: 403,
            message: APIErrorMessages.forbidden,
            errorType: FORBIDDEN(),
          );
        case 422:
          return ResponseModel(
            success: false,
            statusCode: 422,
            data: error.response?.data?['errors'],
            message:
                error.response?.data?['message'] ?? APIErrorMessages.validation,
            errorType: VALIDATION_ERROR(),
          );
        case 500:
          return ResponseModel(
            success: false,
            statusCode: 500,
            message: APIErrorMessages.server,
            errorType: SERVER_ERROR(),
          );
        default:
          return ResponseModel(
            success: false,
            message: APIErrorMessages.unknown,
            errorType: OTHER(),
            statusCode: error.response?.statusCode,
          );
      }
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
      return ResponseModel(
        success: false,
        message: APIErrorMessages.noInternet,
        errorType: NO_INTERNET(),
      );
    case DioExceptionType.receiveTimeout:
      return ResponseModel(
        success: false,
        message: APIErrorMessages.noInternet,
        errorType: RECIEVE_TIMEOUT(),
      );
    case DioExceptionType.sendTimeout:
      return ResponseModel(
        success: false,
        message: APIErrorMessages.noInternet,
        errorType: SEND_TIMEOUT(),
      );
    case DioExceptionType.cancel:
      return ResponseModel(
        success: false,
        errorType: CANCELED(),
        message: APIErrorMessages.canceled,
      );
  }
}
