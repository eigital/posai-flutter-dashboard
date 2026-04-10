import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/shell_theme.dart';
import 'reports_overview_data.dart';

/// Dual-line mini chart — parity with React [MiniChartCard] in [reports-overview.tsx].
class ReportsOverviewMiniChartCard extends StatelessWidget {
  const ReportsOverviewMiniChartCard({
    super.key,
    required this.def,
    required this.metricId,
    required this.editMode,
    required this.showDragHandle,
    required this.onRemove,
  });

  final ReportMetricDef def;
  final String metricId;
  final bool editMode;
  final bool showDragHandle;
  final VoidCallback onRemove;

  static const _lineCurrent = Color(0xFF22C55E);
  static const _linePrevious = Color(0xFFB91C48);

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final details = getReportMetricDetails(metricId);
    final chartData = generateReportChartData(
      metricId,
      details.baseValue,
      def.valueType,
      details.period,
    );
    final yCfg = getReportYAxisConfig(chartData, def.valueType);
    final changeNegative = details.change.startsWith('-');

    final spotsCurrent = chartData.map((e) => FlSpot(e.idx.toDouble(), e.value)).toList();
    final spotsPrev = chartData.map((e) => FlSpot(e.idx.toDouble(), e.previousValue)).toList();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: shell.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: shell.sidebarBorder),
          ),
          padding: const EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                def.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            Icon(Icons.info_outline, size: 14, color: scheme.onSurface.withValues(alpha: 0.45)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                details.change,
                                style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.65)),
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
                              def.value,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.primary,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              details.change,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: changeNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.55),
                                ),
                            children: [
                              TextSpan(
                                text: details.comparison,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' ${details.period}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: LineChart(
                  LineChartData(
                    minY: yCfg.minY,
                    maxY: yCfg.maxY,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (value, meta) {
                            final span = (yCfg.maxY - yCfg.minY).abs();
                            final eps = span > 0 ? span * 0.02 : 0.01;
                            final nearTick = yCfg.ticks.any((t) => (value - t).abs() <= eps);
                            if (!nearTick) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                formatReportValue(value, def.valueType),
                                style: TextStyle(fontSize: 10, color: scheme.onSurface.withValues(alpha: 0.45)),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipColor: (_) => shell.popoverBackground,
                        // fl_chart requires tooltipItems.length == touchedSpots.length (one per line hit).
                        getTooltipItems: (spots) {
                          if (spots.isEmpty) return [];
                          final idx = spots.first.x.toInt();
                          ReportChartPoint? pt;
                          if (idx >= 0 && idx < chartData.length) pt = chartData[idx];
                          pt ??= chartData.first;
                          final p = pt;
                          final style = TextStyle(fontSize: 10, color: scheme.onSurface, height: 1.25);
                          return spots.asMap().entries.map((e) {
                            final i = e.key;
                            final spot = e.value;
                            final isPrev = spot.barIndex == 0;
                            final v = isPrev ? p.previousValue : p.value;
                            final dateStr = isPrev ? p.previousDate : p.date;
                            final line =
                                '${isPrev ? 'Previous' : 'Current'} ($dateStr): ${formatReportValue(v, def.valueType)}';
                            if (i == 0) {
                              return LineTooltipItem('${def.title}\n$line', style);
                            }
                            return LineTooltipItem(line, style);
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spotsPrev,
                        isCurved: false,
                        color: _linePrevious.withValues(alpha: 0.65),
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
                      ),
                      LineChartBarData(
                        spots: spotsCurrent,
                        isCurved: false,
                        color: _lineCurrent,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (s, p, bar, i) => FlDotCirclePainter(
                            radius: 3,
                            color: _lineCurrent,
                            strokeWidth: 1,
                            strokeColor: shell.cardBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: shell.sidebarBorder),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    details.dateRangeStart,
                    style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  Text(
                    details.dateRangeEnd,
                    style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go(reportViewMoreRoute(metricId)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View more',
                    style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.55)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (editMode)
          Positioned(
            top: -4,
            right: -4,
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
    );
  }
}
