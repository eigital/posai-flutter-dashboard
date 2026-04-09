/// Visual Supabase connectivity diagnostic.
///
/// Temporarily add to routes in [main.dart] for manual testing:
///   '/supabase-diag': (context) => const SupabaseDiagnosticPage(),
///
/// Remove before shipping to production.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eo_dashboard_flutter/config/supabase_config.dart';
import 'package:eo_dashboard_flutter/integrations/supabase/supabase_client.dart';

enum _CheckStatus { pending, running, ok, fail }

class _Check {
  _Check(this.label);
  final String label;
  _CheckStatus status = _CheckStatus.pending;
  String detail = '';
}

class SupabaseDiagnosticPage extends StatefulWidget {
  const SupabaseDiagnosticPage({super.key});

  @override
  State<SupabaseDiagnosticPage> createState() => _SupabaseDiagnosticPageState();
}

class _SupabaseDiagnosticPageState extends State<SupabaseDiagnosticPage> {
  final List<_Check> _checks = [
    _Check('Configuration (dart-define)'),
    _Check('Client initialised'),
    _Check('Auth — GoTrue reachable'),
    _Check('Storage — list buckets'),
    _Check('Storage bucket initializer'),
  ];

  bool _running = false;

  @override
  void initState() {
    super.initState();
    _runAll();
  }

  Future<void> _runAll() async {
    if (_running) return;
    setState(() {
      _running = true;
      for (final c in _checks) {
        c.status = _CheckStatus.pending;
        c.detail = '';
      }
    });

    await _run(0, _checkConfig);
    await _run(1, _checkClient);
    await _run(2, _checkAuth);
    await _run(3, _checkStorage);
    await _run(4, _checkBucketInit);

    setState(() => _running = false);
  }

  Future<void> _run(int idx, Future<String> Function() fn) async {
    setState(() => _checks[idx].status = _CheckStatus.running);
    try {
      final detail = await fn();
      setState(() {
        _checks[idx].status = _CheckStatus.ok;
        _checks[idx].detail = detail;
      });
    } catch (e) {
      setState(() {
        _checks[idx].status = _CheckStatus.fail;
        _checks[idx].detail = e.toString();
      });
    }
  }

  Future<String> _checkConfig() async {
    if (!supabaseConfigured) {
      throw Exception('SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY not injected.\nPass --dart-define-from-file=dart_defines.json');
    }
    return 'URL: $supabaseUrl';
  }

  Future<String> _checkClient() async {
    final client = supabase;
    return 'SupabaseClient ready (${client.runtimeType})';
  }

  Future<String> _checkAuth() async {
    try {
      await supabaseAuth.signInWithPassword(
        email: 'probe@eatos.test',
        password: 'probe',
      );
      return 'Auth reachable (unexpected sign-in success)';
    } on AuthException catch (e) {
      // Invalid credentials = server is reachable
      return 'GoTrue reachable — "${e.message}"';
    }
  }

  Future<String> _checkStorage() async {
    final buckets = await supabase.storage.listBuckets();
    return 'Storage reachable — ${buckets.isEmpty ? "no buckets yet" : buckets.map((b) => b.name).join(", ")}';
  }

  Future<String> _checkBucketInit() async {
    final result = await initializeStorageBuckets();
    if (result.containsKey('error')) {
      return 'Edge function not deployed (OK in dev): ${result["error"]}';
    }
    return 'Bucket initializer OK: $result';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connectivity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-run all checks',
            onPressed: _running ? null : _runAll,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _checks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final check = _checks[i];
          return _CheckTile(check: check, theme: theme);
        },
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.check, required this.theme});
  final _Check check;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (check.status) {
      _CheckStatus.pending => (Icons.radio_button_unchecked, Colors.grey),
      _CheckStatus.running => (Icons.sync, Colors.blue),
      _CheckStatus.ok => (Icons.check_circle, Colors.green),
      _CheckStatus.fail => (Icons.error, Colors.red),
    };

    return Card(
      child: ListTile(
        leading: check.status == _CheckStatus.running
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, color: color),
        title: Text(check.label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: check.detail.isNotEmpty
            ? Text(check.detail, style: theme.textTheme.bodySmall)
            : null,
      ),
    );
  }
}
