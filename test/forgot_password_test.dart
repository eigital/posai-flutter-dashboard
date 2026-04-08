import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eo_dashboard_flutter/pages/forgot_password_page.dart';
import 'package:eo_dashboard_flutter/theme/app_theme.dart';

void main() {
  testWidgets('Forgot password page shows title and copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const ForgotPasswordPage(),
      ),
    );
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(
      find.textContaining('registered email address'),
      findsOneWidget,
    );
  });
}
