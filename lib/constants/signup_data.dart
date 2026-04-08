import 'dart:math';

/// Mirrors [eatos-live-dashboard/src/pages/SignUp.tsx] `COUNTRIES`.
class SignupCountry {
  const SignupCountry({
    required this.code,
    required this.name,
    required this.flag,
  });

  final String code;
  final String name;
  final String flag;
}

const List<SignupCountry> signupCountries = [
  SignupCountry(code: '+1', name: 'United States', flag: '🇺🇸'),
  SignupCountry(code: '+91', name: 'India', flag: '🇮🇳'),
  SignupCountry(code: '+44', name: 'United Kingdom', flag: '🇬🇧'),
  SignupCountry(code: '+971', name: 'UAE', flag: '🇦🇪'),
  SignupCountry(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦'),
  SignupCountry(code: '+61', name: 'Australia', flag: '🇦🇺'),
  SignupCountry(code: '+81', name: 'Japan', flag: '🇯🇵'),
];

/// Mirrors React `RESTAURANT_TYPES`.
const List<String> restaurantTypes = [
  'Fast Food',
  'Fine Dining',
  'Casual Dining',
  'Cafe',
  'Bar & Grill',
  'Bakery',
  'Food Truck',
  'Buffet',
  'Pizzeria',
  'Other',
];

const String _captchaChars =
    '0123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz';

/// Same algorithm as React `generateCaptcha`.
String generateCaptcha() {
  final r = Random();
  final buf = StringBuffer();
  for (var i = 0; i < 5; i++) {
    buf.write(_captchaChars[r.nextInt(_captchaChars.length)]);
  }
  return buf.toString();
}

SignupCountry? countryByName(String name) {
  for (final c in signupCountries) {
    if (c.name == name) return c;
  }
  return null;
}
