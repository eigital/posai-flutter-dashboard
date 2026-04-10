import 'package:flutter/material.dart';

import '../theme/shell_theme.dart';

/// Placeholder for routes not yet ported (sidebar navigation targets).
class PlaceholderDashboardPage extends StatelessWidget {
  const PlaceholderDashboardPage({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 48, color: shell.sidebarForeground.withValues(alpha: 0.45)),
            const SizedBox(height: 16),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SelectableText(
              path,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
