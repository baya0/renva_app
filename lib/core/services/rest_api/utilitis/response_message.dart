import '../models/response_model.dart';

/// Extracts a human-readable message from a [ResponseModel].
///
/// The backend is inconsistent about error shapes, so this handles all of them
/// in one place instead of every controller re-implementing the same block:
///   * `data` is a Map with `message` / `error`
///   * `data` is a Map with Laravel-style `errors: {field: [..]}` or `errors: [..]`
///   * `data` is a List of message strings
///   * otherwise falls back to `response.message`, then [fallback].
String extractResponseMessage(ResponseModel response, String fallback) {
  try {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();

      final errors = data['errors'];
      if (errors is Map) {
        final messages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            messages.addAll(value.map((e) => e.toString()));
          } else {
            messages.add(value.toString());
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      } else if (errors is List && errors.isNotEmpty) {
        return errors.join('\n');
      }
    } else if (data is List && data.isNotEmpty) {
      return data.join('\n');
    }

    if (response.message.isNotEmpty) return response.message;
  } catch (_) {
    // fall through to the fallback below
  }

  return fallback;
}
