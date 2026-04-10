import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bootstrap/app_state.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home/dashboard_home_page.dart';
import '../pages/login_page.dart';
import '../pages/placeholder_dashboard_page.dart';
import '../pages/signup_page.dart';
import '../pages/supabase_diagnostic_page.dart';
import '../pages/verify_email_page.dart';
import '../shell/dashboard_shell.dart';
import '../widgets/sidebar/sidebar_models.dart';

/// App routing with authenticated [DashboardShell] wrapping shell routes.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authRefresh,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailPage(email: email);
        },
      ),
      GoRoute(
        path: '/supabase-diag',
        builder: (context, state) => const SupabaseDiagnosticPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardHomePage(),
          ),
          GoRoute(
            path: '/dashboard',
            redirect: (context, state) => '/',
          ),
          for (final path in kShellPlaceholderPaths)
            GoRoute(
              path: path,
              builder: (context, state) => PlaceholderDashboardPage(path: path),
            ),
        ],
      ),
    ],
  );
}

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final loc = state.matchedLocation;
  final loggedIn = await authRepository.isLoggedIn();

  final public = {'/login', '/signup', '/forgot-password', '/verify-email', '/supabase-diag'};

  if (!loggedIn && !public.contains(loc)) {
    return '/login';
  }
  if (loggedIn && (loc == '/login' || loc == '/signup' || loc == '/forgot-password')) {
    return '/';
  }
  return null;
}
