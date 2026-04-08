import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eo_dashboard_flutter/api/app_dio.dart';
import 'package:eo_dashboard_flutter/api/normalize_error.dart';
import 'package:eo_dashboard_flutter/constants/cookie_keys.dart';
import 'package:eo_dashboard_flutter/constants/storage_keys.dart';
import 'package:eo_dashboard_flutter/services/payload_utils.dart';

/// Result of [login] (password never stored).
class LoginResult {
  const LoginResult._({required this.ok, this.errorMessage});

  final bool ok;
  final String? errorMessage;

  factory LoginResult.success() => const LoginResult._(ok: true);

  factory LoginResult.failure(String message) => LoginResult._(ok: false, errorMessage: message);
}

/// Mirrors [eatos-live-dashboard/src/services/authService.ts] `login` + persistence.
class AuthRepository {
  AuthRepository(this._prefs) : _dio = createAppDio(_prefs);

  final SharedPreferences _prefs;
  final Dio _dio;

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
    required bool rememberMe,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/login',
        data: <String, dynamic>{
          'username': email,
          'password': password,
          'rememberMeFor30Days': rememberMe,
        },
      );
      final data = response.data;
      if (data == null) {
        return LoginResult.failure('Empty response');
      }
      if (data['success'] == 1) {
        await _persistAfterSuccessfulLogin(data);
        final payload = toPayload(data);
        await _loadStoreSettings(payload['storeId']);
        return LoginResult.success();
      }
      return LoginResult.failure(data['message']?.toString() ?? 'Invalid credentials. Please try again.');
    } on DioException catch (e) {
      return LoginResult.failure(normalizeError(e));
    } catch (e) {
      return LoginResult.failure(normalizeError(e));
    }
  }

  Future<void> _persistAfterSuccessfulLogin(Map<String, dynamic> body) async {
    final payload = toPayload(body);

    Future<void> setIfPresent(String key, dynamic value) async {
      if (value == null) {
        return;
      }
      await _prefs.setString(key, value.toString());
    }

    final role = payload['role'];
    final roleNameResolved = coalesceStr([
      payload['roleName'],
      role is Map ? role['roleName'] : null,
    ]);

    await setIfPresent(cookieKeyToken, payload['token']);
    await setIfPresent(
      cookieKeyEmployeeName,
      coalesceStr([payload['employeeName'], payload['fullname']]),
    );
    await setIfPresent(cookieKeyHas2FA, payload['has2FA']);
    await setIfPresent(cookieKeyStoreId, payload['storeId']);
    await setIfPresent(cookieKeyMainStoreId, payload['mainStoreId']);
    await setIfPresent(cookieKeyMerchantId, payload['merchantId']);
    await setIfPresent(cookieKeyEmployeeId, payload['employeeId']);
    await setIfPresent(cookieKeyRoleName, roleNameResolved);
    await setIfPresent(
      cookieKeyLoggedAccount,
      coalesceStr([payload['loggedAccount'], payload['username']]),
    );
    await setIfPresent(
      cookieKeyEmployeeMobile,
      coalesceStr([payload['employeeMobile'], payload['mobile']]),
    );

    final isSuperAdmin = payload['isSuperAdmin'] == true ||
        payload['superAdmin'] == true ||
        '${payload['superAdminPage'] ?? ''}' == '3' ||
        (roleNameResolved?.toLowerCase().contains('super') ?? false);
    await _prefs.setString(cookieKeySuperAdmin, isSuperAdmin ? '3' : '0');

    for (final perm in permissionList(payload)) {
      final name = perm['permissionName']?.toString();
      if (name == null || name.isEmpty) {
        continue;
      }
      await _prefs.setString(
        permissionCookieKey(name),
        (perm['permissionValue'] ?? '').toString(),
      );
    }

    await _prefs.setString(storageKeyUserData, jsonEncode(payload));
    await _prefs.setString(storageKeyAutoLogin, 'true');
    await _prefs.setString(
      storageKeyTargetLanguage,
      (payload['employeeLanguage'] ?? 'en').toString(),
    );
    await _prefs.setString(storageKeyIsTestMode, '0');
  }

  Future<void> _loadStoreSettings(dynamic storeId) async {
    if (storeId == null) {
      return;
    }
    if (storeId.toString().trim().isEmpty) {
      return;
    }
    try {
      final res = await _dio.get<dynamic>(
        '/settings',
        queryParameters: <String, dynamic>{'storeId': storeId.toString()},
      );
      await applyStoreSettings(_prefs, res.data);
    } catch (_) {
      /* non-fatal */
    }
  }
}
