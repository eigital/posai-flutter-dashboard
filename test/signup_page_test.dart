import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eo_dashboard_flutter/pages/signup_page.dart';
import 'package:eo_dashboard_flutter/theme/app_theme.dart';

void main() {
  testWidgets('Sign up page shows title and step indicator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const SignUpPage(),
      ),
    );
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Page 1/2'), findsOneWidget);
  });
}
