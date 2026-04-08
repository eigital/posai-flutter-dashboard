import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/login_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_image_slider.dart';

/// Matches [eatos-live-dashboard/src/pages/VerifyEmail.tsx] layout and client checks.
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  final String email;

  static const double lgBreakpoint = 1024;
  static const double formMaxWidth = 448;
  static const double horizontalPadding = 32;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 300;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsRemaining <= 0) return;
      setState(() => _secondsRemaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showVerifiedSnack() {
    final p = EatOsPalette.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verified',
              style: TextStyle(
                color: p.background,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Code verified successfully.',
              style: TextStyle(color: p.background),
            ),
          ],
        ),
        backgroundColor: p.foreground,
      ),
    );
  }

  void _submit() {
    if (_otpCode.length < 4) {
      setState(() => _otpError = 'Please enter the right code!');
      return;
    }
    setState(() => _otpError = null);
    _showVerifiedSnack();
  }

  void _onOtpChanged(int index, String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final one = digitsOnly.isEmpty ? '' : digitsOnly[digitsOnly.length - 1];
    if (_controllers[index].text != one) {
      _controllers[index].text = one;
      _controllers[index].selection =
          TextSelection.collapsed(offset: one.length);
    }
    setState(() => _otpError = null);
    if (one.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _backToForgot() {
    Navigator.of(context).pushReplacementNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    final theme = Theme.of(context);
    final logoAsset =
        theme.brightness == Brightness.dark ? loginLogoDark : loginLogoLight;
    final year = DateTime.now().year;
    final email = widget.email;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= VerifyEmailPage.lgBreakpoint;
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
                        VerifyEmailPage.horizontalPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: VerifyEmailPage.formMaxWidth,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: _backToForgot,
                                style: TextButton.styleFrom(
                                  foregroundColor: p.mutedForeground,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: p.mutedForeground,
                                ),
                                label: Text(
                                  'Back',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: p.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email Verification',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text.rich(
                              TextSpan(
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: p.mutedForeground,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'We have sent an instruction to your email. Please enter the 4 digit code sent to ',
                                  ),
                                  TextSpan(
                                    text: email.isEmpty ? '—' : email,
                                    style: TextStyle(
                                      color: p.foreground,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (i) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: i == 0 ? 0 : 16,
                                  ),
                                  child: SizedBox(
                                    width: 64,
                                    height: 64,
                                    child: Focus(
                                      onKeyEvent: (node, event) {
                                        if (event is! KeyDownEvent) {
                                          return KeyEventResult.ignored;
                                        }
                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.backspace) {
                                          if (_controllers[i]
                                                  .text
                                                  .isEmpty &&
                                              i > 0) {
                                            _focusNodes[i - 1]
                                                .requestFocus();
                                          }
                                        }
                                        return KeyEventResult.ignored;
                                      },
                                      child: TextField(
                                        controller: _controllers[i],
                                        focusNode: _focusNodes[i],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        maxLength: 1,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          counterText: '',
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onChanged: (v) =>
                                            _onOtpChanged(i, v),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            if (_otpError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _otpError!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              _secondsRemaining > 0
                                  ? _formatTime(_secondsRemaining)
                                  : 'Code expired',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: p.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
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
                                  'Change Password',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
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
