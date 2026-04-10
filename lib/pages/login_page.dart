import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bootstrap/app_state.dart' show authRefresh, authRepository;
import '../constants/login_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_image_slider.dart';

/// Login screen matching [eatos-live-dashboard/src/pages/Login.tsx] layout + API.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const double _lgBreakpoint = 1024;
  static const double _formMaxWidth = 448;
  static const double _horizontalPadding = 32;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _lgBreakpoint;
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
                child: const _LoginFormSide(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginFormSide extends StatelessWidget {
  const _LoginFormSide();

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    return ColoredBox(
      color: p.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LoginPage._horizontalPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LoginPage._formMaxWidth),
            child: const _LoginFormContent(),
          ),
        ),
      ),
    );
  }
}

class _LoginFormContent extends StatefulWidget {
  const _LoginFormContent();

  @override
  State<_LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<_LoginFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _showPassword = false;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      if (await authRepository.isLoggedIn()) {
        if (!mounted) {
          return;
        }
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final result = await authRepository.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      // rememberMe: _rememberMe,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    final p = EatOsPalette.of(context);
    if (result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login successful! Redirecting...',
            style: TextStyle(color: p.background),
          ),
          backgroundColor: p.foreground,
        ),
      );
      authRefresh.notifyAuthChanged();
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Login failed',
            style: TextStyle(color: p.background),
          ),
          backgroundColor: p.foreground,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    final theme = Theme.of(context);
    final logoAsset =
        theme.brightness == Brightness.dark ? loginLogoDark : loginLogoLight;
    final year = DateTime.now().year;

    return Form(
      key: _formKey,
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
          'Sign In',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Text(
          'Email',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocus);
          },
          decoration: const InputDecoration(
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Password',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: !_showPassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
                color: p.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Text(
                      'Remember me for 30 days',
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/forgot-password');
              },
              style: TextButton.styleFrom(
                foregroundColor: p.primary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: p.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: AppTheme.inputHeight,
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: p.foreground,
              foregroundColor: p.background,
              disabledBackgroundColor: p.foreground.withValues(alpha: 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: _isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: p.background,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Signing in...',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: p.background,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Log in',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: p.background,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'New to eatOS? '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () {
                    context.push('/signup');
                  },
                  child: Text(
                    'Create a New Account',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: p.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: p.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: theme.textTheme.bodySmall,
            children: [
              TextSpan(
                text: 'Would you prefer to sign in using a magic link instead, ',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  color: p.mutedForeground,
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'sign in with magic link instead.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: p.primary,
                      decoration: TextDecoration.underline,
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
          'Version: 6.0.1 © eatOS POS Inc. 2017-$year',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'By continuing to eatOS, you agree to the eatOS Customer Agreement and other '
          'agreement for eatOS services, and the Privacy Notice. This site uses essential '
          'cookies. See our Cookie Notice for more information.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
      ),
    );
  }
}
