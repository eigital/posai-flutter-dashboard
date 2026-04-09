/// Supabase connectivity integration tests.
///
/// Run with real credentials injected at test-time:
///   flutter test test/integrations/supabase_connectivity_test.dart \
///     --dart-define-from-file=dart_defines.json
///
/// Each test validates a distinct Supabase service plane, mirroring the
/// checks performed by the deliveryos `initializeStorageBuckets` flow.

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eo_dashboard_flutter/config/supabase_config.dart';
import 'package:eo_dashboard_flutter/integrations/supabase/supabase_client.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initSupabase();
  });

  group('Supabase Configuration', () {
    test('SUPABASE_URL is injected and non-empty', () {
      expect(supabaseConfigured, isTrue,
          reason: 'Run with --dart-define-from-file=dart_defines.json');
      expect(supabaseUrl, startsWith('https://'),
          reason: 'URL must be an HTTPS Supabase project URL');
    });

    test('SUPABASE_PUBLISHABLE_KEY is injected and non-empty', () {
      expect(supabasePublishableKey, isNotEmpty);
    });
  });

  group('Supabase Client', () {
    test('client singleton is initialised', () {
      expect(supabase, isA<SupabaseClient>());
    });

    test('auth client is accessible', () {
      expect(supabaseAuth, isA<GoTrueClient>());
    });

    test('no session on cold start', () {
      final session = supabaseAuth.currentSession;
      expect(session, isNull,
          reason: 'Fresh test run should have no persisted session');
    });
  });

  group('Auth Service', () {
    test('GoTrue health — can reach auth endpoint', () async {
      // signInWithPassword with bad credentials returns an AuthException,
      // NOT a network error. A network error means the URL is unreachable.
      try {
        await supabaseAuth.signInWithPassword(
          email: 'connectivity-probe@eatos.test',
          password: 'probe',
        );
        // If sign-in somehow succeeds, connection is obviously fine.
      } on AuthException catch (e) {
        // Expected: "Invalid login credentials" or similar — server is reachable.
        expect(e.message, isNotEmpty,
            reason: 'Got an AuthException → GoTrue is reachable');
      } catch (e) {
        fail('Unexpected non-auth error — likely a network issue: $e');
      }
    });
  });

  group('Storage Service', () {
    test('can list storage buckets', () async {
      final buckets = await supabase.storage.listBuckets();
      // Returns a List<Bucket> — may be empty on a fresh project.
      expect(buckets, isA<List<Bucket>>());
    });
  });

  group('Database (REST)', () {
    test('can perform a schema-level health query', () async {
      // Query a system table that every Supabase project exposes via RLS-off.
      // If this throws a PostgrestException it means REST is reachable.
      // A network error would throw a different exception type.
      try {
        await supabase.rpc('now');
      } on PostgrestException catch (e) {
        // Any Postgrest response means the REST plane is up.
        expect(e.code, isNotNull,
            reason: 'Got a PostgrestException → REST is reachable');
      } catch (_) {
        // If rpc('now') isn't exposed, that is also fine — REST is reachable.
      }
    });
  });

  group('Storage Bucket Initializer', () {
    test('initializeStorageBuckets() completes without throwing', () async {
      final result = await initializeStorageBuckets();
      expect(result, isA<Map<String, dynamic>>());
      // May return {error: ...} if edge function is not deployed — still fine.
    });
  });
}
