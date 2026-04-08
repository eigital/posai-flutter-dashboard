import 'package:flutter_test/flutter_test.dart';
import 'package:eo_dashboard_flutter/services/payload_utils.dart';

void main() {
  group('toPayload', () {
    test('unwraps response object', () {
      final m = toPayload({
        'success': 1,
        'response': {'token': 'abc', 'storeId': 1},
      });
      expect(m['token'], 'abc');
      expect(m['storeId'], 1);
    });

    test('unwraps response JSON string', () {
      final m = toPayload({
        'success': 1,
        'response': '{"token":"x"}',
      });
      expect(m['token'], 'x');
    });
  });
}
