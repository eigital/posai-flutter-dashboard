import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/dashboard/breakdown_report.dart';
import '../../widgets/dashboard/dashboard_resource_cards.dart';
import '../../widgets/dashboard/glass_card.dart';
import '../../widgets/dashboard/reports_overview.dart';
import '../../widgets/dashboard/unified_metrics_dashboard.dart';

/// React route `/` — [eatos-live-dashboard/src/pages/Dashboard.tsx].
class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardHomeBody();
  }
}

class _DashboardHomeBody extends StatelessWidget {
  const _DashboardHomeBody();

  @override
  Widget build(BuildContext context) {
    final p = EatOsPalette.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _GlassTitleBlock(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => context.go('/sales-transaction'),
                    child: Text('View Details', style: TextStyle(color: p.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const UnifiedMetricsDashboard(),
              const SizedBox(height: 20),
              const BreakdownReport(),
              const SizedBox(height: 20),
              const ReportsOverview(),
              const SizedBox(height: 20),
              const DashboardResourceCards(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTitleBlock extends StatefulWidget {
  const _GlassTitleBlock();

  @override
  State<_GlassTitleBlock> createState() => _GlassTitleBlockState();
}

class _GlassTitleBlockState extends State<_GlassTitleBlock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLine = DateFormat('EEEE, MMMM d, yyyy').format(_now);
    final timeLine = DateFormat('h:mm a').format(_now);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 520;
          final row = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor your restaurant performance and key metrics',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ),
              if (!narrow) _ClockColumn(dateLine: dateLine, timeLine: timeLine),
            ],
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row,
                const SizedBox(height: 16),
                _ClockColumn(dateLine: dateLine, timeLine: timeLine),
              ],
            );
          }
          return row;
        },
      ),
    );
  }
}

class _ClockColumn extends StatelessWidget {
  const _ClockColumn({required this.dateLine, required this.timeLine});

  final String dateLine;
  final String timeLine;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(dateLine, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(timeLine, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
      ],
    );
  }
}
