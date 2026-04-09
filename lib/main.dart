import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'bootstrap/app_state.dart';
import 'config/supabase_config.dart';
import 'pages/dashboard_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/verify_email_page.dart';
import 'services/auth_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isSupabaseConfigured) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } else {
    debugLogSupabaseSkipped();
  }
  final prefs = await SharedPreferences.getInstance();
  authRepository = AuthRepository(prefs);
  runApp(const EatOsDashboardApp());
}

class EatOsDashboardApp extends StatelessWidget {
  const EatOsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eatOS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routes: {
        '/dashboard': (context) => const DashboardPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/verify-email': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final email = args is String ? args : '';
          return VerifyEmailPage(email: email);
        },
      },
      home: const LoginPage(),
    );
  }
}
