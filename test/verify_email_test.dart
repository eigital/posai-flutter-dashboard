import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eo_dashboard_flutter/pages/verify_email_page.dart';
import 'package:eo_dashboard_flutter/theme/app_theme.dart';

void main() {
  testWidgets('Verify email page shows title and email', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const VerifyEmailPage(email: 'user@example.com'),
      ),
    );
    expect(find.text('Email Verification'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.text('5:00'), findsOneWidget);
  });
}
