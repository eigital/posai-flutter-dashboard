import 'package:flutter/material.dart';

import 'package:eo_dashboard_flutter/bootstrap/app_state.dart';

/// Placeholder post-login screen until the full dashboard is ported.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () async {
              await authRepository.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            child: const Text('Log out'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Signed in — dashboard shell (replace with real routes later).'),
      ),
    );
  }
}
