import 'package:flutter/material.dart';

import '../../../theme/shell_theme.dart';
import 'kpi_formatting.dart';

/// Tailwind `warning` analogue (amber).
Color kWarningColor(BuildContext context) {
  return const Color(0xFFF59E0B);
}

class DetailShellCard extends StatelessWidget {
  const DetailShellCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(0),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: shell.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: shell.sidebarBorder),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class DetailedMetricCard extends StatelessWidget {
  const DetailedMetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.trendUp,
    required this.badgeLabel,
    required this.badgeStyle,
    required this.description,
    this.badgeBottomMargin = false,
  });

  final String title;
  final IconData icon;
  final String value;
  /// Trend icon: up vs down (matches React `metric.change > 0`).
  final bool trendUp;
  final String badgeLabel;
  final KpiChipStyle badgeStyle;
  final String description;
  final bool badgeBottomMargin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.55);
    final shell = EatOsShellTheme.of(context);
    final up = trendUp;
    return DetailShellCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(icon, size: 20, color: muted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                up ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: up ? shell.success : shell.destructive,
              ),
              const SizedBox(width: 8),
              _KpiChip(label: badgeLabel, style: badgeStyle),
            ],
          ),
          if (badgeBottomMargin) const SizedBox(height: 8),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

enum KpiChipStyle { success, destructive, warning, benchmarkExcellent, benchmarkGood, benchmarkWarning, benchmarkPoor, neutral }

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.label, required this.style});

  final String label;
  final KpiChipStyle style;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    late Color bg;
    late Color fg;
    late Color border;
    switch (style) {
      case KpiChipStyle.success:
        bg = shell.success.withValues(alpha: 0.1);
        fg = shell.success;
        border = shell.success.withValues(alpha: 0.2);
      case KpiChipStyle.destructive:
        bg = shell.destructive.withValues(alpha: 0.1);
        fg = shell.destructive;
        border = shell.destructive.withValues(alpha: 0.2);
      case KpiChipStyle.warning:
        bg = w.withValues(alpha: 0.1);
        fg = w;
        border = w.withValues(alpha: 0.2);
      case KpiChipStyle.benchmarkExcellent:
      case KpiChipStyle.benchmarkGood:
        bg = shell.success.withValues(alpha: 0.1);
        fg = shell.success;
        border = shell.success.withValues(alpha: 0.2);
      case KpiChipStyle.benchmarkWarning:
        bg = w.withValues(alpha: 0.1);
        fg = w;
        border = w.withValues(alpha: 0.2);
      case KpiChipStyle.benchmarkPoor:
        bg = shell.destructive.withValues(alpha: 0.1);
        fg = shell.destructive;
        border = shell.destructive.withValues(alpha: 0.2);
      case KpiChipStyle.neutral:
        bg = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
        fg = Theme.of(context).colorScheme.onSurface;
        border = Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

KpiChipStyle benchmarkStatusToChipStyle(BenchmarkStatus s) {
  switch (s) {
    case BenchmarkStatus.excellent:
    case BenchmarkStatus.good:
      return KpiChipStyle.benchmarkExcellent;
    case BenchmarkStatus.warning:
      return KpiChipStyle.benchmarkWarning;
    case BenchmarkStatus.poor:
      return KpiChipStyle.benchmarkPoor;
  }
}

String benchmarkStatusLabel(BenchmarkStatus s) {
  final t = s.name;
  return t[0].toUpperCase() + t.substring(1);
}

/// Shadcn-like full-width 5 segments, `h-10` track, `p-1`.
class KpmSegmentedTabBar extends StatelessWidget {
  const KpmSegmentedTabBar({
    super.key,
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SizedBox(
          height: 40,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: shell.mutedSolid,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: List.generate(labels.length, (i) {
                final selected = controller.index == i;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          controller.animateTo(i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? shell.cardBackground : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: scheme.shadow.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
