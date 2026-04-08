import 'package:dio/dio.dart';

/// Same extraction order as [eatos-live-dashboard/src/lib/api.ts] `normalizeError`.
String normalizeError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      final err = data['error'];
      if (err is String && err.trim().isNotEmpty) {
        return err;
      }
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is String && first.trim().isNotEmpty) {
          return first;
        }
        if (first is Map && first['message'] is String) {
          return (first['message'] as String).trim();
        }
      }
    }
    final msg = error.message;
    if (msg != null && msg.trim().isNotEmpty) {
      return msg;
    }
  }
  final s = error.toString();
  if (s.trim().isNotEmpty) {
    return s;
  }
  return 'Something went wrong';
}
