import 'package:flutter/foundation.dart';

/// Supabase project URL (compile-time via `--dart-define` or `--dart-define-from-file`).
///
/// Set `SUPABASE_URL` in your defines file (see repository README).
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);

/// Supabase **publishable** or legacy **anon** API key (compile-time).
///
/// Passed to [Supabase.initialize] as `anonKey`. Never use the service_role key here.
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: '',
);

/// Whether both URL and client key were provided at build time.
bool get isSupabaseConfigured =>
    supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

/// Logs a single debug message when Supabase was not configured (empty defines).
void debugLogSupabaseSkipped() {
  if (kDebugMode && !isSupabaseConfigured) {
    debugPrint(
      'Supabase: SUPABASE_URL / SUPABASE_ANON_KEY not set; '
      'use --dart-define-from-file=dart_defines/supabase.defs.json (see README).',
    );
  }
}
