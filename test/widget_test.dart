import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eo_dashboard_flutter/bootstrap/app_state.dart';
import 'package:eo_dashboard_flutter/main.dart';
import 'package:eo_dashboard_flutter/services/auth_repository.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    authRepository = AuthRepository(prefs);
  });

  testWidgets('Login page shows Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(const EatOsDashboardApp());
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
