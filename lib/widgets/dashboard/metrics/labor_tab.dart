import 'package:flutter/material.dart';

import '../../../theme/shell_theme.dart';
import 'detailed_metric_ui.dart';
import 'kpi_formatting.dart';
import 'restaurant_kpi_data.dart';

class LaborTabContent extends StatelessWidget {
  const LaborTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final d = kRestaurantKpis.labor;
    final b = kRestaurantKpis.benchmarks;

    final laborCostChange = calculatePercentageChange(d.laborCostPercentage, d.previousPeriod.laborCostPercentage);
    final salesPerHourChange = calculatePercentageChange(d.salesPerLaborHour, d.previousPeriod.salesPerLaborHour);
    final benchStatus = getBenchmarkStatus(d.laborCostPercentage, b.laborCostTarget.band);

    final metrics = <_LaborMetric>[
      _LaborMetric(
        title: 'Total Labor Cost',
        value: formatCurrency(d.totalLaborCost),
        change: calculatePercentageChange(d.totalLaborCost, d.previousPeriod.totalLaborCost),
        icon: Icons.attach_money,
        description: 'Total wages, benefits, and payroll taxes',
      ),
      _LaborMetric(
        title: 'Labor Cost %',
        value: formatPercentage(d.laborCostPercentage),
        change: laborCostChange,
        icon: Icons.track_changes,
        description: 'Target: ${formatPercentage(b.laborCostTarget.ideal)}',
        benchmark: true,
        status: benchStatus,
      ),
      _LaborMetric(
        title: 'Sales per Labor Hour',
        value: formatCurrency(d.salesPerLaborHour),
        change: salesPerHourChange,
        icon: Icons.schedule,
        description: 'Revenue generated per hour worked',
      ),
      _LaborMetric(
        title: 'Staff Efficiency Score',
        value: '${d.staffEfficiencyScore}%',
        change: 2.3,
        icon: Icons.people_outline,
        description: 'Overall productivity measurement',
      ),
      _LaborMetric(
        title: 'Overtime Cost',
        value: formatCurrency(d.overtimeCost),
        change: -8.5,
        icon: Icons.warning_amber_outlined,
        description: '${d.overtimeHours} hours of overtime',
      ),
      _LaborMetric(
        title: 'Labor Cost per Customer',
        value: formatCurrency(d.laborCostPerCustomer),
        change: -2.1,
        icon: Icons.people_outline,
        description: 'Labor efficiency per customer served',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 1024 ? 3 : (c.maxWidth >= 768 ? 2 : 1);
            const gap = 16.0;
            final itemW = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: metrics.map((m) {
                final chipStyle = m.benchmark && m.status != null
                    ? benchmarkStatusToChipStyle(m.status!)
                    : (m.change > 0 ? KpiChipStyle.success : KpiChipStyle.destructive);
                final chipLabel = m.benchmark && m.status != null
                    ? benchmarkStatusLabel(m.status!)
                    : (m.change > 0 ? '+${formatPercentage(m.change)}' : formatPercentage(m.change));
                return SizedBox(
                  width: itemW,
                  child: DetailedMetricCard(
                    title: m.title,
                    icon: m.icon,
                    value: m.value,
                    trendUp: m.change > 0,
                    badgeLabel: chipLabel,
                    badgeStyle: chipStyle,
                    description: m.description,
                    badgeBottomMargin: true,
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            final three = c.maxWidth >= 1024;
            if (three) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _laborBenchmarkCard(context, d, b)),
                  const SizedBox(width: 12),
                  Expanded(child: _efficiencyCard(context, d)),
                  const SizedBox(width: 12),
                  Expanded(child: _laborActionsCard(context, d, b)),
                ],
              );
            }
            return Column(
              children: [
                _laborBenchmarkCard(context, d, b),
                const SizedBox(height: 12),
                _efficiencyCard(context, d),
                const SizedBox(height: 12),
                _laborActionsCard(context, d, b),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _laborBenchmarkCard(BuildContext context, LaborMetricsData d, IndustryBenchmarksData b) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final pct = (d.laborCostPercentage / b.laborCostTarget.max) * 100;
    final onTarget = d.laborCostPercentage <= b.laborCostTarget.max;
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Labor Cost Benchmark', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text('Current vs Target', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
          Text(
            '${formatPercentage(d.laborCostPercentage)} / ${formatPercentage(b.laborCostTarget.max)}%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            onTarget ? '✅ On Target' : '⚠️ Over Target',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }

  Widget _efficiencyCard(BuildContext context, LaborMetricsData d) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final shell = EatOsShellTheme.of(context);
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Labor Efficiency Insights', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Productive', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
                    Text('${d.productiveLaborHours}h', style: TextStyle(fontWeight: FontWeight.w600, color: shell.success)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Non-Prod', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
                    Text('${d.nonProductiveLaborHours}h', style: TextStyle(fontWeight: FontWeight.w600, color: kWarningColor(context))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Efficiency Score: ${d.staffEfficiencyScore}%',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }

  Widget _laborActionsCard(BuildContext context, LaborMetricsData d, IndustryBenchmarksData b) {
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Labor Management Action Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (d.laborCostPercentage > b.laborCostTarget.max)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _actionBox(context, 'High Cost Alert', shell.destructive, 0.05, 0.2),
            ),
          if (d.overtimeHours > 15)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _actionBox(context, 'Reduce Overtime', w, 0.05, 0.2),
            ),
          _actionBoxAccent(context, 'Cross-Training'),
        ],
      ),
    );
  }

  Widget _actionBox(BuildContext context, String text, Color c, double bgA, double brA) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: bgA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: brA)),
      ),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Widget _actionBoxAccent(BuildContext context, String text) {
    final shell = EatOsShellTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: shell.sidebarAccent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: shell.sidebarBorder),
      ),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: shell.sidebarForeground)),
    );
  }
}

class _LaborMetric {
  const _LaborMetric({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.description,
    this.benchmark = false,
    this.status,
  });

  final String title;
  final String value;
  final double change;
  final IconData icon;
  final String description;
  final bool benchmark;
  final BenchmarkStatus? status;
}
