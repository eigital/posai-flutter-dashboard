import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/login_assets.dart';
import '../constants/signup_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_image_slider.dart';

/// Sign-up flow matching [eatos-live-dashboard/src/pages/SignUp.tsx] (UI + client checks).
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const double lgBreakpoint = 1024;
  static const double formMaxWidth = 448;
  static const double horizontalPadding = 32;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _step = 1;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _phone = TextEditingController();
  final _restaurantName = TextEditingController();
  final _address1 = TextEditingController();
  final _address2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _zipCode = TextEditingController();
  final _captchaInput = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String _country = 'India';
  bool _smsConsent = false;

  String _restaurantType = '';
  bool _sellerAgreement = false;
  String _captchaCode = generateCaptcha();

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _phone.dispose();
    _restaurantName.dispose();
    _address1.dispose();
    _address2.dispose();
    _city.dispose();
    _state.dispose();
    _zipCode.dispose();
    _captchaInput.dispose();
    super.dispose();
  }

  void _showErrorSnack(String message) {
    final p = EatOsPalette.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: p.background)),
        backgroundColor: p.foreground,
      ),
    );
  }

  void _showSuccessSnack(String message) {
    final p = EatOsPalette.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: p.background)),
        backgroundColor: p.foreground,
      ),
    );
  }

  void _handleNext() {
    final fn = _firstName.text.trim();
    final ln = _lastName.text.trim();
    final em = _email.text.trim();
    final pw = _password.text;
    final cp = _confirmPassword.text;
    if (fn.isEmpty ||
        ln.isEmpty ||
        em.isEmpty ||
        pw.isEmpty ||
        cp.isEmpty) {
      _showErrorSnack('Please fill in all required fields.');
      return;
    }
    if (pw != cp) {
      _showErrorSnack('Passwords do not match.');
      return;
    }
    setState(() => _step = 2);
  }

  void _handleFinish() {
    final rn = _restaurantName.text.trim();
    final rt = _restaurantType.trim();
    if (rn.isEmpty || rt.isEmpty) {
      _showErrorSnack('Please fill in restaurant details.');
      return;
    }
    if (!_sellerAgreement) {
      _showErrorSnack('Please accept the Seller Agreement.');
      return;
    }
    if (_captchaInput.text.trim().toLowerCase() !=
        _captchaCode.toLowerCase()) {
      _showErrorSnack(
        'Security code does not match. Please try again.',
      );
      return;
    }
    _showSuccessSnack('Account created successfully!');
  }

  void _regenerateCaptcha() {
    setState(() {
      _captchaCode = generateCaptcha();
      _captchaInput.clear();
    });
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    final theme = Theme.of(context);
    final logoAsset =
        theme.brightness == Brightness.dark ? loginLogoDark : loginLogoLight;
    final year = DateTime.now().year;
    final selectedCountry = countryByName(_country);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= SignUpPage.lgBreakpoint;
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
                        SignUpPage.horizontalPadding,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: SignUpPage.formMaxWidth,
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
                            if (_step == 2) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _step = 1),
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
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                  ),
                                ),
                                Text(
                                  'Page $_step/2',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: p.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (_step == 1) _buildStep1(
                              context,
                              p,
                              theme,
                              selectedCountry,
                            )
                            else
                              _buildStep2(context, p, theme),
                            const SizedBox(height: 20),
                            Text.rich(
                              TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'Have an account? '),
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
                            const SizedBox(height: 16),
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

  Widget _buildStep1(
    BuildContext context,
    EatOsPalette p,
    ThemeData theme,
    SignupCountry? selectedCountry,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'First Name',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Enter First Name',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Last Name',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Enter Last Name',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Email', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        Text('Password', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _password,
          obscureText: !_showPassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Password',
            suffixIcon: IconButton(
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              onPressed: () =>
                  setState(() => _showPassword = !_showPassword),
              icon: Icon(
                _showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: p.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Confirm Password', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPassword,
          obscureText: !_showConfirmPassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Password',
            suffixIcon: IconButton(
              tooltip: _showConfirmPassword
                  ? 'Hide password'
                  : 'Show password',
              onPressed: () => setState(
                () => _showConfirmPassword = !_showConfirmPassword,
              ),
              icon: Icon(
                _showConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: p.mutedForeground,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Country', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(isDense: true),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _country,
              items: signupCountries
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c.name,
                      child: Text('${c.flag} ${c.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _country = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Phone Number', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: AppTheme.inputHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                color: p.background,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedCountry?.flag ?? '🇮🇳'),
                  const SizedBox(width: 4),
                  Text(
                    selectedCountry?.code ?? '+91',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: '74104 10123',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _smsConsent,
              onChanged: (v) =>
                  setState(() => _smsConsent = v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: _smsConsentLabel(theme, p),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: AppTheme.inputHeight + 4,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleNext,
            style: OutlinedButton.styleFrom(
              foregroundColor: p.foreground,
              side: BorderSide(color: p.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: Text(
              'Next',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _smsConsentLabel(ThemeData theme, EatOsPalette p) {
    final small = theme.textTheme.bodySmall?.copyWith(
      color: p.mutedForeground,
      height: 1.35,
    );
    final linkStyle = TextStyle(
      color: p.primary,
      decoration: TextDecoration.underline,
      decorationColor: p.primary,
      fontSize: small?.fontSize,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I agree to receive automated transactional text messages from eatOS '
          'related to my account, orders, payments, and security.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: small,
            children: [
              const TextSpan(
                text:
                    '(Message frequency varies. Msg & data rates may apply. Reply STOP to cancel or HELP for help. View our ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () {},
                  child: Text('SMS Terms', style: linkStyle),
                ),
              ),
              const TextSpan(text: ' and '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () {},
                  child: Text('Privacy Policy', style: linkStyle),
                ),
              ),
              const TextSpan(text: '.)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, EatOsPalette p, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Restaurant Name', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _restaurantName,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'Restaurant Name',
          ),
        ),
        const SizedBox(height: 16),
        Text('Restaurant Type', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(isDense: true),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _restaurantType.isEmpty ? null : _restaurantType,
              hint: Text(
                'Select Restaurant Type',
                style: TextStyle(color: p.mutedForeground),
              ),
              items: restaurantTypes
                  .map(
                    (t) => DropdownMenuItem<String>(
                      value: t,
                      child: Text(t),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _restaurantType = v ?? ''),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Restaurant Address', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _address1,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'Address 1',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _address2,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            isDense: true,
            hintText: 'Address 2',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _city,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'City',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _state,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'State',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _zipCode,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Zip Code',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _sellerAgreement,
              onChanged: (v) =>
                  setState(() => _sellerAgreement = v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: _sellerAgreementLabel(theme, p),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _captchaCard(theme, p),
        const SizedBox(height: 16),
        SizedBox(
          height: AppTheme.inputHeight + 4,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleFinish,
            style: OutlinedButton.styleFrom(
              foregroundColor: p.foreground,
              side: BorderSide(color: p.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: Text(
              'Finish Sign Up',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sellerAgreementLabel(ThemeData theme, EatOsPalette p) {
    final base = theme.textTheme.bodyMedium?.copyWith(height: 1.35);
    final linkStyle = TextStyle(
      color: p.primary,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: p.primary,
      fontSize: base?.fontSize,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: "eatOS's "),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () {},
              child: Text('Seller Agreement', style: linkStyle),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () {},
              child: Text('e-Sign Consent', style: linkStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _captchaCard(ThemeData theme, EatOsPalette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Security Check',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Guess words and characters seen in image below. Can't read this? Try another.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: p.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: SizedBox(
                    height: 64,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: p.input),
                        CustomPaint(
                          painter: _CaptchaNoisePainter(
                            _captchaCode.hashCode,
                            p.primary,
                          ),
                        ),
                        Center(
                          child: Text(
                            _captchaCode,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              fontFamily: 'monospace',
                              color: p.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'New code',
                onPressed: _regenerateCaptcha,
                icon: Icon(Icons.refresh, color: p.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _captchaInput,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Enter Code',
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptchaNoisePainter extends CustomPainter {
  _CaptchaNoisePainter(this.seed, this.lineColor);

  final int seed;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Random(seed);
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(r.nextDouble() * size.width, 0),
        Offset(r.nextDouble() * size.width, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CaptchaNoisePainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.lineColor != lineColor;
}
