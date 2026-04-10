import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Matches [eatos-live-dashboard/src/components/simple-footer.tsx].
class SimpleFooter extends StatelessWidget {
  const SimpleFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);
    final muted = p.mutedForeground;
    final year = DateTime.now().year;

    return Material(
      color: p.background,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 520;
            final links = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Link(text: 'Privacy Policy', color: muted),
                _Sep(color: muted),
                _Link(text: 'Legal & Terms', color: muted),
                _Sep(color: muted),
                _Link(text: 'Report Fraud', color: muted),
              ],
            );
            final version = Text(
              'Version: 6.0.1 © eatOS POS Inc. 2017-$year. All Rights Reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
              textAlign: narrow ? TextAlign.center : TextAlign.end,
            );
            if (narrow) {
              return Column(
                children: [
                  Wrap(alignment: WrapAlignment.center, spacing: 0, runSpacing: 8, children: [
                    links,
                  ]),
                  const SizedBox(height: 8),
                  version,
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: links)),
                const SizedBox(width: 16),
                Flexible(child: version),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('|', style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
