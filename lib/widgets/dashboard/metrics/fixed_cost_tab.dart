import 'package:flutter/material.dart';

import '../../../theme/shell_theme.dart';
import 'detailed_metric_ui.dart';
import 'kpi_formatting.dart';
import 'restaurant_kpi_data.dart';

class FixedCostTabContent extends StatelessWidget {
  const FixedCostTabContent({super.key});

  static const double _salesBase = 45000;

  @override
  Widget build(BuildContext context) {
    final d = kRestaurantKpis.fixedCost;
    final b = kRestaurantKpis.benchmarks;

    final rentChange = calculatePercentageChange(d.rentPercentage, d.previousPeriod.rentPercentage);
    final utilitiesChange = calculatePercentageChange(d.utilitiesCost, d.previousPeriod.utilitiesCost);
    final totalFixedChange = calculatePercentageChange(d.totalFixedCosts, d.previousPeriod.totalFixedCosts);
    final rentBench = getBenchmarkStatus(d.rentPercentage, b.rentTarget.band);

    final metrics = <_FxMetric>[
      _FxMetric(
        title: 'Rent as % of Sales',
        value: formatPercentage(d.rentPercentage),
        change: rentChange,
        icon: Icons.home_outlined,
        description: 'Target: ${formatPercentage(b.rentTarget.ideal)}%',
        benchmark: true,
        status: rentBench,
      ),
      _FxMetric(
        title: 'Utilities Cost',
        value: formatCurrency(d.utilitiesCost),
        change: utilitiesChange,
        icon: Icons.bolt_outlined,
        description: 'Electricity, gas, water, internet',
      ),
      _FxMetric(
        title: 'Insurance Cost',
        value: formatCurrency(d.insuranceCost),
        change: 2.1,
        icon: Icons.shield_outlined,
        description: 'General liability, workers comp, etc.',
      ),
      _FxMetric(
        title: 'License & Permits',
        value: formatCurrency(d.licenseCost),
        change: 0,
        icon: Icons.credit_card,
        description: 'Business licenses and permits',
      ),
      _FxMetric(
        title: 'Equipment Depreciation',
        value: formatCurrency(d.equipmentDepreciation),
        change: 0,
        icon: Icons.build_outlined,
        description: 'Monthly equipment depreciation',
      ),
      _FxMetric(
        title: 'Marketing Spend',
        value: formatCurrency(d.marketingSpend),
        change: 15.3,
        icon: Icons.campaign_outlined,
        description: 'ROI: ${d.marketingROI.toStringAsFixed(1)}x',
      ),
      _FxMetric(
        title: 'Administrative Costs',
        value: formatCurrency(d.administrativeCosts),
        change: -3.2,
        icon: Icons.calculate_outlined,
        description: 'Accounting, legal, office expenses',
      ),
      _FxMetric(
        title: 'Total Fixed Costs',
        value: formatCurrency(d.totalFixedCosts),
        change: totalFixedChange,
        icon: Icons.track_changes,
        description: 'All fixed operating expenses',
      ),
    ];

    final costBreakdown = <_Breakdown>[
      _Breakdown('Rent', (d.rentPercentage / 100) * _salesBase, d.rentPercentage),
      _Breakdown('Marketing', d.marketingSpend, (d.marketingSpend / _salesBase) * 100),
      _Breakdown('Equipment', d.equipmentDepreciation, (d.equipmentDepreciation / _salesBase) * 100),
      _Breakdown('Administrative', d.administrativeCosts, (d.administrativeCosts / _salesBase) * 100),
      _Breakdown('Utilities', d.utilitiesCost, (d.utilitiesCost / _salesBase) * 100),
      _Breakdown('Insurance', d.insuranceCost, (d.insuranceCost / _salesBase) * 100),
      _Breakdown('Licenses', d.licenseCost, (d.licenseCost / _salesBase) * 100),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 1200 ? 4 : (c.maxWidth >= 768 ? 2 : 1);
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
            if (c.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _rentBenchmarkCard(context, d, b, rentChange)),
                  const SizedBox(width: 16),
                  Expanded(child: _breakdownCard(context, costBreakdown)),
                ],
              );
            }
            return Column(
              children: [
                _rentBenchmarkCard(context, d, b, rentChange),
                const SizedBox(height: 16),
                _breakdownCard(context, costBreakdown),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _marketingRoiCard(context, d)),
                  const SizedBox(width: 16),
                  Expanded(child: _fixedActionsCard(context, d, b, utilitiesChange)),
                ],
              );
            }
            return Column(
              children: [
                _marketingRoiCard(context, d),
                const SizedBox(height: 16),
                _fixedActionsCard(context, d, b, utilitiesChange),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _rentBenchmarkCard(BuildContext context, FixedCostMetricsData d, IndustryBenchmarksData b, double rentChange) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final within = d.rentPercentage <= b.rentTarget.max;
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rent Benchmark Analysis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current: ${formatPercentage(d.rentPercentage)}', style: const TextStyle(fontSize: 13)),
              Text(
                'Target: ${formatPercentage(b.rentTarget.min)}-${formatPercentage(b.rentTarget.max)}%',
                style: TextStyle(fontSize: 13, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (d.rentPercentage / b.rentTarget.max).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('vs Previous Period', style: TextStyle(fontSize: 13, color: muted)),
              _rentChangeChip(context, rentChange),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            within ? '✅ Within industry benchmark range' : '⚠️ Above recommended range',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }

  Widget _rentChangeChip(BuildContext context, double rentChange) {
    final shell = EatOsShellTheme.of(context);
    final good = rentChange <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (good ? shell.success : shell.destructive).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (good ? shell.success : shell.destructive).withValues(alpha: 0.2)),
      ),
      child: Text(
        '${rentChange > 0 ? '+' : ''}${formatPercentage(rentChange)}',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: good ? shell.success : shell.destructive),
      ),
    );
  }

  Widget _breakdownCard(BuildContext context, List<_Breakdown> rows) {
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fixed Cost Breakdown', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...rows.map((cost) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cost.category, style: const TextStyle(fontSize: 13)),
                      Text(formatCurrency(cost.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (cost.percentage / 100).clamp(0, 1),
                            minHeight: 4,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${formatPercentage(cost.percentage)} of sales', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _marketingRoiCard(BuildContext context, FixedCostMetricsData d) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final shell = EatOsShellTheme.of(context);
    final rev = d.marketingSpend * d.marketingROI;
    String roiNote() {
      if (d.marketingROI >= 3) return '✅ Excellent marketing efficiency';
      if (d.marketingROI >= 2) return '✓ Good marketing performance';
      return '⚠️ Review marketing strategies';
    }

    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Marketing ROI Analysis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('${d.marketingROI.toStringAsFixed(1)}x', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
                Text('Return on Marketing Investment', style: TextStyle(fontSize: 13, color: muted)),
              ],
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Marketing Spend', style: TextStyle(fontSize: 13, color: muted)),
              Text(formatCurrency(d.marketingSpend), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Revenue Generated', style: TextStyle(fontSize: 13, color: muted)),
              Text(formatCurrency(rev), style: TextStyle(fontWeight: FontWeight.w600, color: shell.success)),
            ],
          ),
          const SizedBox(height: 8),
          Text(roiNote(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
        ],
      ),
    );
  }

  Widget _fixedActionsCard(BuildContext context, FixedCostMetricsData d, IndustryBenchmarksData b, double utilitiesChange) {
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final pctOfSales = (d.totalFixedCosts / _salesBase) * 100;
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fixed Cost Action Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (d.rentPercentage > b.rentTarget.max)
            _alertBlock(
              context,
              'High Rent Alert',
              'Rent is ${formatPercentage(d.rentPercentage - b.rentTarget.max)} above target',
              shell.destructive,
              muted,
            ),
          if (d.marketingROI < 2)
            _alertBlock(
              context,
              'Low Marketing ROI',
              'Review and optimize marketing strategies',
              w,
              muted,
            ),
          if (utilitiesChange > 10)
            _alertBlock(
              context,
              'Rising Utility Costs',
              'Consider energy efficiency improvements',
              w,
              muted,
            ),
          _alertBlock(
            context,
            'Cost Control',
            'Fixed costs are ${formatPercentage(pctOfSales)} of total sales',
            shell.success,
            muted,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: shell.sidebarAccent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: shell.sidebarBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Optimization Tip', style: TextStyle(fontWeight: FontWeight.w600, color: shell.sidebarForeground)),
                const SizedBox(height: 4),
                Text('Negotiate contracts and consider consolidating vendors', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertBlock(BuildContext context, String title, String sub, Color c, Color muted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: c)),
            const SizedBox(height: 4),
            Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
          ],
        ),
      ),
    );
  }
}

class _FxMetric {
  const _FxMetric({
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

class _Breakdown {
  _Breakdown(this.category, this.amount, this.percentage);

  final String category;
  final double amount;
  final double percentage;
}
