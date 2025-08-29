// ignore_for_file: constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:dio/dio.dart';

enum RequestMethod {
  Get,
  Post,
  Put,
  Patch,
  Delete;

  String get value => name.toUpperCase();
}

class Request<T> {
  ///Type of request [RequestMethod]
  RequestMethod method;

  ///Api end point
  String endPoint;

  ///Is the end point has the base url or not
  bool isFullURL;

  ///Used for deactivate request
  late CancelToken cancelToken;

  ///Custom header
  Map<String, dynamic>? header;

  ///Copy header
  Map<String, dynamic>? copyHeader;

  ///Request params
  Map<String, dynamic>? params;

  ///Body of the Request
  var body;

  ///Listener for receiving data
  Function(int count, int total)? onReceiveProgress;

  ///Listener for sending data
  Function(int count, int total)? onSendProgress;

  ///Optional Modelling
  T Function(Map<String, dynamic> json)? fromJson;

  Request({
    required this.endPoint,
    this.isFullURL = false,
    this.method = RequestMethod.Get,
    this.header,
    this.copyHeader,
    this.params,
    this.body,
    CancelToken? cancelToken,
    this.fromJson,
    this.onReceiveProgress,
    this.onSendProgress,
  }) {
    if (header != null && copyHeader != null) {
      throw Exception("Can't pass both header and copyHeader when creating Request instance");
    }
    if (method == RequestMethod.Get && (body != null || onSendProgress != null)) {
      throw Exception("Get request must not have body or onSendProgress parameters");
    }
    if (cancelToken == null) {
      this.cancelToken = CancelToken();
    } else {
      this.cancelToken = cancelToken;
    }
  }

  stop() {
    cancelToken.cancel();
  }
}
