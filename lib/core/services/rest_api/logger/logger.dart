import 'dart:developer';

import 'package:get/get.dart';

import '../api_service.dart';
import '../models/request.dart';
import '../models/response_model.dart';

requestingLogger(Request request) {
  if (!Get.find<APIService>().withLog) return;
  log('############# API Service ###############\n', name: "API SERVICE");
  log(
    'Requesting ${request.method.name} ${request.endPoint}',
    name: "API SERVICE",
  );
  log('Params     ${request.params}', name: "API SERVICE");
  if (request.body != null) {
    if (request.body is FormData) {
      log('Body files:       ${request.body.files}', name: "API SERVICE");
      log('Body fields:      ${request.body.fields}', name: "API SERVICE");
    } else {
      log('Body       ${request.body}', name: "API SERVICE");
    }
  }
  log('#########################################', name: "API SERVICE");
}

resultLogger(Request request, ResponseModel response) {
  if (!Get.find<APIService>().withLog) return;
  log('############# API Service ###############\n', name: "API SERVICE");
  log(
    'Response of ${request.method.name} ${request.endPoint}',
    name: "API SERVICE",
  );
  log('${response.toJson()}', name: "API SERVICE");
  log('#########################################', name: "API SERVICE");
}

headerLogger(Map header) {
  try {
    if (!Get.find<APIService>().withLog) return;
  } catch (_) {}
  log('############# API Service ###############\n', name: "API SERVICE");
  log('Main Header', name: "API SERVICE");
  log('$header', name: "API SERVICE");
  log('#########################################', name: "API SERVICE");
}
