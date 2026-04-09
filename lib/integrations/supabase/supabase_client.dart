/// Supabase client singleton for the Flutter dashboard.
///
/// Mirrors `deliveryos/src/integrations/supabase/client.ts`:
///   - Single shared [SupabaseClient] instance.
///   - Exposes [supabaseAuth] for convenience (mirrors `export const auth`).
///   - Exposes [initializeStorageBuckets] for the delivery-photos bucket.
///
/// Usage:
///   import 'package:eo_dashboard_flutter/integrations/supabase/supabase_client.dart';
///
///   // Auth
///   await supabaseAuth.signInWithPassword(email: email, password: password);
///
///   // Realtime / database
///   final stream = supabase.from('orders').stream(primaryKey: ['id']);

library;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eo_dashboard_flutter/config/supabase_config.dart';

/// The initialised [SupabaseClient].
///
/// Available after [initSupabase] has been awaited in [main].
SupabaseClient get supabase => Supabase.instance.client;

/// Convenience accessor for [SupabaseClient.auth].
///
/// Mirrors `export const auth = supabase.auth` in the deliveryos TS client.
GoTrueClient get supabaseAuth => supabase.auth;

/// Initialise the Supabase singleton.
///
/// Must be called once before [runApp] — typically the first statement in
/// [main] after [WidgetsFlutterBinding.ensureInitialized].
///
/// Credentials are resolved from build-time dart-defines via [supabaseConfig].
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
    debug: false,
  );
}

/// Initialises the `delivery-photos` storage bucket via an Edge Function.
///
/// Mirrors `initializeStorageBuckets` in the deliveryos TS client.
/// Non-fatal — logs errors but never throws.
Future<Map<String, dynamic>> initializeStorageBuckets() async {
  try {
    final response = await supabase.functions.invoke(
      'create-delivery-photos-bucket',
      method: HttpMethod.post,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'data': data};
  } catch (error) {
    // Non-fatal — bucket may already exist or function unavailable.
    return {'error': error.toString()};
  }
}
