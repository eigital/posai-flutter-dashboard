import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/shell_theme.dart';
import '../../utils/comparison_utils.dart';
import 'breakdown_report_data.dart';

/// Parity with React [BreakdownMetricCard] in [breakdown-report.tsx].
class BreakdownMetricCard extends StatelessWidget {
  const BreakdownMetricCard({
    super.key,
    required this.metric,
    required this.comparisonData,
    required this.comparisonLabel,
    required this.hourlyPoints,
    required this.editMode,
    required this.showDragHandle,
    this.onRemove,
  });

  final BreakdownMetricDef metric;
  final CuComparisonData comparisonData;
  final String comparisonLabel;
  final List<BreakdownHourPoint> hourlyPoints;
  final bool editMode;
  final bool showDragHandle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final badge = breakdownBadgeStyle(metric, comparisonData);
    String displayPrimary() {
      if (metric.id == 'cost-vs-revenue') return '${metric.baseValue}:1';
      return formatBreakdownValue(metric, comparisonData.currentValue);
    }

    String displayCompare() {
      if (metric.id == 'cost-vs-revenue') return 'Optimal';
      return formatBreakdownValue(metric, comparisonData.previousValue);
    }

    final spotsPrev =
        hourlyPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.previous)).toList();
    final spotsCur =
        hourlyPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.current)).toList();
    final allY = <double>[
      ...hourlyPoints.expand((p) => [p.current, p.previous]),
    ];
    var minY = allY.reduce(min);
    var maxY = allY.reduce(max);
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    } else {
      final pad = (maxY - minY) * 0.08;
      minY -= pad;
      maxY += pad;
    }

    final c = metric.seriesColor;
    final prevColor = c.withValues(alpha: 0.55);
    final labels = hourlyPoints.map((p) => p.time).toList();

    Widget chart = LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[i],
                    style: TextStyle(fontSize: 9, color: scheme.onSurface.withValues(alpha: 0.45)),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => shell.popoverBackground,
            getTooltipItems: (spots) {
              if (spots.isEmpty) return [];
              final idx = spots.first.x.toInt().clamp(0, hourlyPoints.length - 1);
              final timeLabel = hourlyPoints[idx].time;
              final style = TextStyle(fontSize: 10, color: scheme.onSurface, height: 1.25);
              return spots.asMap().entries.map((e) {
                final i = e.key;
                final spot = e.value;
                final isPrev = spot.barIndex == 0;
                final v = isPrev ? hourlyPoints[idx].previous : hourlyPoints[idx].current;
                final line =
                    '${isPrev ? 'Previous' : 'Current'}: ${formatBreakdownValue(metric, v)}';
                if (i == 0) {
                  return LineTooltipItem('Time: $timeLabel\n$line', style);
                }
                return LineTooltipItem(line, style);
              }).toList();
            },
          ),
        ),
        lineBarsData: metric.chartType == BreakdownChartType.area
            ? [
                LineChartBarData(
                  spots: spotsPrev,
                  isCurved: true,
                  color: prevColor,
                  barWidth: 1,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: prevColor.withValues(alpha: 0.22),
                  ),
                ),
                LineChartBarData(
                  spots: spotsCur,
                  isCurved: true,
                  color: c,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: c.withValues(alpha: 0.35),
                  ),
                ),
              ]
            : [
                LineChartBarData(
                  spots: spotsPrev,
                  isCurved: true,
                  color: prevColor,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  dashArray: [4, 4],
                ),
                LineChartBarData(
                  spots: spotsCur,
                  isCurved: true,
                  color: c,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, p, bar, ix) => FlDotCirclePainter(
                      radius: 2,
                      color: c,
                      strokeWidth: 1,
                      strokeColor: shell.cardBackground,
                    ),
                  ),
                ),
              ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: shell.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: shell.sidebarBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDragHandle) ...[
                        Icon(Icons.drag_indicator, size: 18, color: scheme.onSurface.withValues(alpha: 0.35)),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                metric.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: scheme.onSurface.withValues(alpha: 0.65),
                                    ),
                              ),
                            ),
                            Icon(Icons.info_outline, size: 14, color: scheme.onSurface.withValues(alpha: 0.45)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        displayPrimary(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: scheme.primary,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'vs',
                        style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.45)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayCompare(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface.withValues(alpha: 0.55),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        comparisonData.isPositive ? Icons.north_east : Icons.south_east,
                        size: 14,
                        color: comparisonData.isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badge.background,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badge.foreground.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          badge.text,
                          style: TextStyle(fontSize: 11, color: badge.foreground, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          comparisonLabel,
                          style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.45)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final r = breakdownViewMoreRoute(metric.id);
                          if (r != null) context.go(r);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View more',
                          style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.55)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (editMode && onRemove != null)
              Positioned(
                top: -8,
                right: -8,
                child: Material(
                  color: scheme.error,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [metric.gradientLeft, metric.gradientRight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: chart,
        ),
      ],
    );
  }
}
