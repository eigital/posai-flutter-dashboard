import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eo_dashboard_flutter/config/api_config.dart';
import 'package:eo_dashboard_flutter/constants/cookie_keys.dart';

/// Shared [Dio] with 30s timeouts and [Authorization] header from session (React parity).
Dio createAppDio(SharedPreferences prefs) {
  final dio = Dio(
    BaseOptions(
      baseUrl: resolveApiBaseUrl(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = prefs.getString(cookieKeyToken);
        if (token != null && token.trim().isNotEmpty) {
          options.headers['Authorization'] = token;
        }
        handler.next(options);
      },
    ),
  );
  return dio;
}
