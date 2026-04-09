import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eo_dashboard_flutter/api/normalize_error.dart';
import 'package:eo_dashboard_flutter/config/supabase_config.dart';
import 'package:eo_dashboard_flutter/constants/cookie_keys.dart';
import 'package:eo_dashboard_flutter/constants/storage_keys.dart';
import 'package:eo_dashboard_flutter/integrations/supabase/supabase_client.dart';
import 'package:eo_dashboard_flutter/services/payload_utils.dart';

/// Result of [login] (password never stored).
class LoginResult {
  const LoginResult._({required this.ok, this.errorMessage});

  final bool ok;
  final String? errorMessage;

  factory LoginResult.success() => const LoginResult._(ok: true);

  factory LoginResult.failure(String message) => LoginResult._(ok: false, errorMessage: message);
}

/// Local session marker for Supabase RPC login — not a eatOS API JWT.
const String _supabaseSessionTokenPlaceholder = 'supabase_rpc';

/// Login via Supabase `login_with_email_password` RPC + SharedPreferences persistence.
class AuthRepository {
  AuthRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Whether session looks valid (token + userData), matching [authService.isAuthenticated].
  Future<bool> isLoggedIn() async {
    final token = _prefs.getString(cookieKeyToken);
    final userData = _prefs.getString(storageKeyUserData);
    return token != null &&
        token.trim().isNotEmpty &&
        userData != null &&
        userData.trim().isNotEmpty;
  }

  Future<void> logout() async {
    await _prefs.clear();
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    if (!supabaseConfigured) {
      return LoginResult.failure(
        'Supabase is not configured. Build with --dart-define=SUPABASE_URL=<url> '
        'and --dart-define=SUPABASE_PUBLISHABLE_KEY=<anon-key>.',
      );
    }
    try {
      final raw = await supabase.rpc(
        'login_with_email_password',
        params: <String, dynamic>{
          'p_email': email,
          'p_password': password,
        },
      );
      final data = _asStringKeyMap(raw);
      if (data == null) {
        return LoginResult.failure('Empty response');
      }
      final success = data['success'];
      final ok = success == 1 || success == '1';
      if (!ok) {
        return LoginResult.failure(
          data['message']?.toString() ?? 'Invalid credentials. Please try again.',
        );
      }
      await _persistAfterSupabaseRpc(data);
      return LoginResult.success();
    } on PostgrestException catch (e) {
      return LoginResult.failure(e.message);
    } catch (e) {
      return LoginResult.failure(normalizeError(e));
    }
  }

  Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<void> _persistAfterSupabaseRpc(Map<String, dynamic> rpcBody) async {
    final payload = Map<String, dynamic>.from(toPayload(rpcBody));
    final first = payload['first_name']?.toString().trim() ?? '';
    final last = payload['last_name']?.toString().trim() ?? '';
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (full.isNotEmpty) {
      payload['fullname'] = full;
      payload['employeeName'] = full;
    }
    payload['authProvider'] = 'supabase';

    await _prefs.setString(cookieKeyToken, _supabaseSessionTokenPlaceholder);
    final email = payload['email']?.toString();
    if (email != null && email.isNotEmpty) {
      await _prefs.setString(cookieKeyLoggedAccount, email);
    }
    final displayName = coalesceStr([full, email]);
    if (displayName != null && displayName.isNotEmpty) {
      await _prefs.setString(cookieKeyEmployeeName, displayName);
    }

    await _prefs.setString(storageKeyUserData, jsonEncode(payload));
    await _prefs.setString(storageKeyAutoLogin, 'true');
    await _prefs.setString(storageKeyTargetLanguage, 'en');
    await _prefs.setString(storageKeyIsTestMode, '0');
    await _prefs.setString(cookieKeySuperAdmin, '0');
  }
}
