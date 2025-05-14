// ignore_for_file: prefer_typing_uninitialized_variables

import '../constants/api_error.dart';

class ResponseModel<T> {
  late bool success;
  late String message;
  int? statusCode;
  APIError? errorType;
  T? data;

  ResponseModel({
    required this.success,
    this.data,
    required this.message,
    this.errorType,
    this.statusCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success;
    data['status_code'] = statusCode;
    data['data'] = this.data;
    data['message'] = message;
    data['code'] = errorType;
    return data;
  }
}
