import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../theme/shell_theme.dart';
import 'detailed_metric_ui.dart';
import 'kpi_formatting.dart';
import 'restaurant_kpi_data.dart';

class FoodCostTabContent extends StatelessWidget {
  const FoodCostTabContent({super.key});

  static const _chartColors = [
    Color(0xFF2563EB),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
  ];

  @override
  Widget build(BuildContext context) {
    final d = kRestaurantKpis.foodCost;
    final b = kRestaurantKpis.benchmarks;

    final foodCostChange = calculatePercentageChange(d.foodCostPercentage, d.previousPeriod.foodCostPercentage);
    final cogsChange = calculatePercentageChange(d.costOfGoodsSold, d.previousPeriod.costOfGoodsSold);
    final wasteChange = calculatePercentageChange(d.foodWastePercentage, d.previousPeriod.foodWastePercentage);
    final benchStatus = getBenchmarkStatus(d.foodCostPercentage, b.foodCostTarget.band);

    final metrics = <_FcMetric>[
      _FcMetric(
        title: 'Food Cost %',
        value: formatPercentage(d.foodCostPercentage),
        change: foodCostChange,
        icon: Icons.track_changes,
        description: 'Target: ${formatPercentage(b.foodCostTarget.ideal)}%',
        benchmark: true,
        status: benchStatus,
      ),
      _FcMetric(
        title: 'Cost of Goods Sold',
        value: formatCurrency(d.costOfGoodsSold),
        change: cogsChange,
        icon: Icons.attach_money,
        description: 'Total food and beverage costs',
      ),
      _FcMetric(
        title: 'Food Waste %',
        value: formatPercentage(d.foodWastePercentage),
        change: wasteChange,
        icon: Icons.delete_outline,
        description: 'Percentage of food wasted',
      ),
      _FcMetric(
        title: 'Inventory Turnover',
        value: '${d.inventoryTurnoverRate}x',
        change: 8.3,
        icon: Icons.inventory_2_outlined,
        description: 'Inventory turns per period',
      ),
      _FcMetric(
        title: 'Theoretical vs Actual',
        value: '+${formatPercentage(d.theoreticalVsActualFoodCost)}',
        change: -12.5,
        icon: Icons.bar_chart_outlined,
        description: 'Variance from theoretical cost',
      ),
      _FcMetric(
        title: 'Average Recipe Cost',
        value: formatCurrency(d.averageRecipeCost),
        change: 3.2,
        icon: Icons.attach_money,
        description: 'Mean cost per recipe',
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
            if (c.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _benchmarkCard(context, d, b, foodCostChange)),
                  const SizedBox(width: 16),
                  Expanded(child: _vendorChartCard(context, d)),
                ],
              );
            }
            return Column(
              children: [
                _benchmarkCard(context, d, b, foodCostChange),
                const SizedBox(height: 16),
                _vendorChartCard(context, d),
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
                  Expanded(child: _costControlCard(context, d)),
                  const SizedBox(width: 16),
                  Expanded(child: _foodActionsCard(context, d, b)),
                ],
              );
            }
            return Column(
              children: [
                _costControlCard(context, d),
                const SizedBox(height: 16),
                _foodActionsCard(context, d, b),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _benchmarkCard(BuildContext context, FoodCostMetricsData d, IndustryBenchmarksData b, double foodCostChange) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final within = d.foodCostPercentage <= b.foodCostTarget.max;
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Cost Benchmark Analysis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current: ${formatPercentage(d.foodCostPercentage)}', style: const TextStyle(fontSize: 13)),
              Text(
                'Target: ${formatPercentage(b.foodCostTarget.min)}-${formatPercentage(b.foodCostTarget.max)}%',
                style: TextStyle(fontSize: 13, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (d.foodCostPercentage / b.foodCostTarget.max).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('vs Previous Period', style: TextStyle(fontSize: 13, color: muted)),
              _chipPct(context, foodCostChange),
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

  Widget _chipPct(BuildContext context, double foodCostChange) {
    final shell = EatOsShellTheme.of(context);
    final good = foodCostChange <= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (good ? shell.success : shell.destructive).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (good ? shell.success : shell.destructive).withValues(alpha: 0.2)),
      ),
      child: Text(
        '${foodCostChange > 0 ? '+' : ''}${formatPercentage(foodCostChange)}',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: good ? shell.success : shell.destructive),
      ),
    );
  }

  Widget _vendorChartCard(BuildContext context, FoodCostMetricsData d) {
    final keys = ['Proteins', 'Produce', 'Dairy', 'Beverages'];
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vendor Cost Trends', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: -5,
                maxY: 5,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= 5) return const SizedBox.shrink();
                        return Text('Month ${i + 1}', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: List.generate(4, (lineIdx) {
                  final key = keys[lineIdx];
                  final pts = d.vendorCostTrends[key]!;
                  return LineChartBarData(
                    spots: List.generate(pts.length, (i) => FlSpot(i.toDouble(), pts[i])),
                    color: _chartColors[lineIdx],
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(4, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _chartColors[i], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(keys[i], style: const TextStyle(fontSize: 11)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _costControlCard(BuildContext context, FoodCostMetricsData d) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cost Control Insights', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _insightRow(context, 'Inventory Efficiency', '${d.inventoryTurnoverRate}x turnover', shell.success, muted),
          const SizedBox(height: 12),
          _insightRow(context, 'Recipe Cost Variance', '+${formatPercentage(d.theoreticalVsActualFoodCost)}', w, muted),
          const SizedBox(height: 12),
          _insightRow(context, 'Waste Impact on Margin', '-${formatPercentage(d.foodWastePercentage * 0.3)}', shell.destructive, muted),
        ],
      ),
    );
  }

  Widget _insightRow(BuildContext context, String k, String v, Color vColor, Color muted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: TextStyle(fontSize: 13, color: muted)),
        Text(v, style: TextStyle(fontWeight: FontWeight.w600, color: vColor)),
      ],
    );
  }

  Widget _foodActionsCard(BuildContext context, FoodCostMetricsData d, IndustryBenchmarksData b) {
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Cost Action Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (d.foodCostPercentage > b.foodCostTarget.max)
            _bigAlert(
              context,
              'Food Cost Alert',
              'Cost is ${formatPercentage(d.foodCostPercentage - b.foodCostTarget.max)} above target',
              shell.destructive,
            ),
          if (d.foodWastePercentage > 5)
            _bigAlert(
              context,
              'High Waste Alert',
              'Implement portion control and inventory management',
              w,
            ),
          if (d.theoreticalVsActualFoodCost > 3)
            _bigAlert(
              context,
              'Recipe Variance',
              'Review portion sizes and ingredient costs',
              w,
            ),
          _bigAlertNeutral(context, 'Optimization Tip', 'Negotiate with vendors and optimize menu engineering', muted),
        ],
      ),
    );
  }

  Widget _bigAlert(BuildContext context, String title, String sub, Color c) {
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
            Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
          ],
        ),
      ),
    );
  }

  Widget _bigAlertNeutral(BuildContext context, String title, String sub, Color muted) {
    final shell = EatOsShellTheme.of(context);
    return Container(
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
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: shell.sidebarForeground)),
          const SizedBox(height: 4),
          Text(sub, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
        ],
      ),
    );
  }
}

class _FcMetric {
  const _FcMetric({
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
