import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../constants/api_error.dart';
import '../constants/messages.dart';
import '../models/exceptions.dart';
import '../models/response_model.dart';
import '../utilitis/parser.dart';

///Used for General Response Modelling in success case
Future<ResponseModel> responseModelling<T>(Response response,
    {T Function(Map<String, dynamic> json)? fromJson}) async {
  log(response.toString(), name: "API SERVICE - SUCCESS HANDLER");

  switch (response.statusCode) {
    case 200:
    case 201:
      if (response.data is! Map<String, dynamic>) {
        throw ModellingException(
            'Response.data is not subtype of Type Map<String,dynamic>');
      }
      var data = response.data['data'];

      if (fromJson != null) {
        data = await Parser.parsingDataIsolate(data, fromJson);

        if (data == null) {
          throw ModellingException("Error when recieving data");
        }
      }

      return ResponseModel(
        success: true,
        message: "",
        data: data,
        statusCode: response.statusCode,
      );
    case 204:
      return ResponseModel(
        success: true,
        errorType: NO_CONTENT(),
        data: null,
        message: APIErrorMessages.noData,
      );
    default:
      return ResponseModel(success: true, message: "", data: response.data);
  }
}
