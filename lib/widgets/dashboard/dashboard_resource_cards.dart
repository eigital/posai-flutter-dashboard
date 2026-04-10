import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/shell_theme.dart';

/// Matches [eatos-live-dashboard/src/components/dashboard-resource-cards.tsx].
class DashboardResourceCards extends StatelessWidget {
  const DashboardResourceCards({super.key});

  static final _resources = [
    _Resource(
      title: 'Go to eatOS.com',
      description: 'Visit our main website for the latest updates and features.',
      icon: Icons.open_in_new_rounded,
      url: 'https://eatos.com',
    ),
    _Resource(
      title: 'eatOS Support',
      description: 'Get help from our support team for any issues or questions.',
      icon: Icons.headset_mic_outlined,
      url: null,
    ),
    _Resource(
      title: 'Frequently Asked Questions',
      description: 'Find answers to the most commonly asked questions.',
      icon: Icons.help_outline_rounded,
      url: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget card(_Resource r) {
      return Material(
        color: shell.cardBackground,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            final u = r.url;
            if (u != null) {
              final uri = Uri.parse(u);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
          borderRadius: BorderRadius.circular(8),
          hoverColor: scheme.primary.withValues(alpha: 0.04),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: shell.sidebarBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(r.icon, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        const gap = 16.0;
        if (c.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _resources.length; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                Expanded(child: card(_resources[i])),
              ],
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _resources.length; i++) ...[
              if (i > 0) const SizedBox(height: gap),
              card(_resources[i]),
            ],
          ],
        );
      },
    );
  }
}

class _Resource {
  const _Resource({
    required this.title,
    required this.description,
    required this.icon,
    required this.url,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? url;
}
