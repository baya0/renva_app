import 'dart:developer';
import 'dart:isolate';

abstract class Parser {
  static parsingData<T>(
      var data, T Function(Map<String, dynamic> json) fromJson) {
    if (data is List) {
      List<T> parsed = [];
      try {
        for (var json in data) {
          parsed.add(fromJson(json));
        }
        log(parsed.runtimeType.toString());
        return parsed;
      } catch (e) {
        return null;
      }
    } else if (data is Map<String, dynamic>) {
      try {
        return fromJson(data);
      } catch (_) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<dynamic> parsingDataIsolate<T>(
    var data,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    return await Isolate.run(() => parsingData<T>(data, fromJson));
  }
}
