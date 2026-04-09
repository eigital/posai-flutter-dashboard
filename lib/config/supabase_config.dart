/// Supabase credential resolution.
///
/// Credentials are injected at build-time via `--dart-define` (or
/// `--dart-define-from-file=dart_defines.json`) so they are never stored in
/// source code.
///
/// Local dev example:
///   flutter run -d chrome \
///     --dart-define=SUPABASE_URL=https://aulebjhfrruwsvqngtev.supabase.co \
///     --dart-define=SUPABASE_PUBLISHABLE_KEY=<anon-key>
///
/// CI/CD: set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY as build secrets and
/// forward them via `--dart-define` in your pipeline script.
///
/// Mirrors the pattern in [api_config.dart] and the deliveryos
/// `src/integrations/supabase/client.ts` Supabase client.

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const String _supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY', defaultValue: '');

/// Resolved Supabase project URL.
///
/// Throws [StateError] at runtime if the value was not injected at build-time.
String get supabaseUrl {
  final v = _supabaseUrl.trim();
  assert(v.isNotEmpty, 'SUPABASE_URL is not set. Pass --dart-define=SUPABASE_URL=<url>');
  return v;
}

/// Resolved Supabase anon/publishable key.
///
/// Throws [StateError] at runtime if the value was not injected at build-time.
String get supabasePublishableKey {
  final v = _supabasePublishableKey.trim();
  assert(v.isNotEmpty, 'SUPABASE_PUBLISHABLE_KEY is not set. Pass --dart-define=SUPABASE_PUBLISHABLE_KEY=<key>');
  return v;
}

/// Returns true if both credentials have been provided at build-time.
bool get supabaseConfigured =>
    _supabaseUrl.trim().isNotEmpty && _supabasePublishableKey.trim().isNotEmpty;
