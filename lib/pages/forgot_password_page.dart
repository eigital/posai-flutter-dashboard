import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/login_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_image_slider.dart';

/// Matches [eatos-live-dashboard/src/pages/ForgotPassword.tsx] layout and client checks.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const double lgBreakpoint = 1024;
  static const double formMaxWidth = 448;
  static const double horizontalPadding = 32;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  void _submit() {
    final trimmed = _email.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    setState(() => _emailError = null);
    final p = EatOsPalette.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions Sent',
              style: TextStyle(
                color: p.background,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Password reset instructions have been sent to your email.',
              style: TextStyle(color: p.background),
            ),
          ],
        ),
        backgroundColor: p.foreground,
      ),
    );
    context.push('/verify-email', extra: trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    final theme = Theme.of(context);
    final logoAsset =
        theme.brightness == Brightness.dark ? loginLogoDark : loginLogoLight;
    final year = DateTime.now().year;
    final err = _emailError;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= ForgotPasswordPage.lgBreakpoint;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                const Expanded(
                  flex: 65,
                  child: AuthImageSlider(),
                ),
              Expanded(
                flex: wide ? 35 : 1,
                child: ColoredBox(
                  color: p.background,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        ForgotPasswordPage.horizontalPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: ForgotPasswordPage.formMaxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Image.asset(
                                logoAsset,
                                height: 64,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Forgot Password',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Please enter your registered email address. We will send an '
                              'email with instructions to help you reset the password.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: p.mutedForeground,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Email',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Enter your email',
                                errorText: err,
                                errorMaxLines: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: AppTheme.inputHeight + 4,
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _submit,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: p.foreground,
                                  side: BorderSide(color: p.border),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Send Instructions',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text.rich(
                              TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  const TextSpan(
                                    text:
                                        'Wait a minute, I remember my password. ',
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      onTap: _goToLogin,
                                      child: Text(
                                        'Sign in',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: p.primary,
                                          decoration:
                                              TextDecoration.underline,
                                          decorationColor: p.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Version: 6.0 © eatOS POS Inc. 2017-$year',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: p.mutedForeground,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
