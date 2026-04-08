import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eo_dashboard_flutter/api/normalize_error.dart';

void main() {
  test('extracts message from Dio response map', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        data: {'message': 'Invalid login'},
      ),
    );
    expect(normalizeError(e), 'Invalid login');
  });

  test('falls back to Something went wrong when toString is empty', () {
    expect(normalizeError(_EmptyToString()), 'Something went wrong');
  });
}

class _EmptyToString {
  @override
  String toString() => '';
}
