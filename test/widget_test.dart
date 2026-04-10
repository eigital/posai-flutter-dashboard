import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eo_dashboard_flutter/bootstrap/app_state.dart';
import 'package:eo_dashboard_flutter/bootstrap/auth_refresh.dart';
import 'package:eo_dashboard_flutter/main.dart';
import 'package:eo_dashboard_flutter/pages/login_page.dart';
import 'package:eo_dashboard_flutter/router/app_router.dart';
import 'package:eo_dashboard_flutter/services/auth_repository.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    authRepository = AuthRepository(prefs);
    authRefresh = AuthRefreshNotifier();
    appRouter = createAppRouter();
  });

  testWidgets('Login page shows Sign In', (WidgetTester tester) async {
    await tester.pumpWidget(const EatOsDashboardApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}
