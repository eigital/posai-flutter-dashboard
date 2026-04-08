import 'package:flutter/foundation.dart';

/// Default API origin when not using the dev proxy path prefix (non-web / release).
/// Matches [eatos-live-dashboard/src/config/env.ts].
const String defaultProdApiOrigin = 'https://browserapi.eatos.net';

/// Resolves Dio [BaseOptions.baseUrl].
///
/// - **Web + dev:** `web_dev_config.yaml` serves the app on a fixed port and proxies
///   `/api` → browserapi; use same-origin `${Uri.base.origin}/api`.
/// - **Override:** `--dart-define=API_BASE_URL=https://host` (no trailing slash).
/// - **Non-web:** direct `browserapi` unless `API_BASE_URL` is set.
String resolveApiBaseUrl() {
  const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (env.trim().isNotEmpty) {
    return _trimTrailingSlash(env.trim());
  }
  if (kIsWeb) {
    return '${Uri.base.origin}/api';
  }
  return defaultProdApiOrigin;
}

String _trimTrailingSlash(String s) {
  if (s.endsWith('/')) {
    return s.substring(0, s.length - 1);
  }
  return s;
}
