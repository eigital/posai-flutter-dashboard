import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/dashboard_prefs.dart';
import '../../theme/shell_theme.dart';
import 'reports_overview_card.dart';
import 'reports_overview_data.dart';
import 'unified_metrics_dashboard.dart' show kKpmToolbarHeight;

/// Default visible metric ids — [reports-overview.tsx] `useState` defaults.
const List<String> kDefaultVisibleReportMetrics = [
  'gross-sales',
  'net-sales',
  'total-orders',
  'total-transactions',
  'total-refunds',
  'total-discounts',
  'total-tax',
  'total-tips',
  'total-delivery-fees',
];

/// Parity with React [reports-overview.tsx] + [usePersistentDateFilter] (`reports-overview`).
class ReportsOverview extends StatefulWidget {
  const ReportsOverview({super.key});

  @override
  State<ReportsOverview> createState() => _ReportsOverviewState();
}

class _ReportsOverviewState extends State<ReportsOverview> {
  String _primaryPeriod = 'this-quarter';
  String _comparisonPeriod = 'previous-period';
  List<String> _visibleMetricIds = List<String>.from(kDefaultVisibleReportMetrics);
  bool _editMode = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getString('$kReportsOverviewStorageKey-primary');
    final c = prefs.getString('$kReportsOverviewStorageKey-comparison');
    final raw = prefs.getString(kReportsOverviewMetricsKey);
    if (!mounted) return;
    setState(() {
      if (p != null && p.isNotEmpty && _primaryItems.any((e) => e.$1 == p)) {
        _primaryPeriod = p;
      }
      if (c != null && c.isNotEmpty && _comparisonItems.any((e) => e.$1 == c)) {
        _comparisonPeriod = c;
      }
      if (raw != null && raw.isNotEmpty) {
        try {
          final list = jsonDecode(raw);
          if (list is List && list.every((e) => e is String) && list.isNotEmpty) {
            _visibleMetricIds = List<String>.from(list);
          }
        } catch (_) {}
      }
      _loaded = true;
    });
  }

  Future<void> _saveDatePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$kReportsOverviewStorageKey-primary', _primaryPeriod);
    await prefs.setString('$kReportsOverviewStorageKey-comparison', _comparisonPeriod);
  }

  Future<void> _saveVisibleMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kReportsOverviewMetricsKey, jsonEncode(_visibleMetricIds));
  }

  void _onPrimaryChanged(String? v) {
    if (v == null) return;
    setState(() {
      _primaryPeriod = v;
      _comparisonPeriod = reportDefaultComparisonForPrimary(v);
    });
    _saveDatePrefs();
  }

  void _onComparisonChanged(String? v) {
    if (v == null) return;
    setState(() => _comparisonPeriod = v);
    _saveDatePrefs();
  }

  void _addMetric(String id) {
    if (_visibleMetricIds.contains(id)) return;
    setState(() => _visibleMetricIds = [..._visibleMetricIds, id]);
    _saveVisibleMetrics();
  }

  void _removeMetric(String id) {
    setState(() => _visibleMetricIds = _visibleMetricIds.where((e) => e != id).toList());
    _saveVisibleMetrics();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      var n = newIndex;
      if (n > oldIndex) n -= 1;
      final item = _visibleMetricIds.removeAt(oldIndex);
      _visibleMetricIds.insert(n, item);
    });
    _saveVisibleMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    if (!_loaded) {
      return Card(
        elevation: 0,
        color: shell.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: shell.sidebarBorder),
        ),
        child: const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      );
    }

    final visibleDefs = _visibleMetricIds
        .map(reportMetricById)
        .whereType<ReportMetricDef>()
        .toList();

    return Card(
      elevation: 0,
      color: shell.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: shell.sidebarBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 960;
                final header = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Reports Overview',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 24),
                      ),
                    ),
                    if (wide)
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _headerControls(context),
                          ),
                        ),
                      ),
                  ],
                );
                if (wide) return header;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Reports Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _headerControls(context),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                final maxW = c.maxWidth;
                final colCount = maxW > 1100 ? 3 : maxW > 640 ? 2 : 1;
                final gap = 16.0;
                final tileW = colCount == 1
                    ? maxW
                    : (maxW - gap * (colCount - 1)) / colCount;

                final children = <Widget>[];
                for (var i = 0; i < visibleDefs.length; i++) {
                  final def = visibleDefs[i];
                  children.add(
                    KeyedSubtree(
                      key: ValueKey(def.id),
                      child: SizedBox(
                        width: tileW.clamp(260, 520),
                        child: ReportsOverviewMiniChartCard(
                          def: def,
                          metricId: def.id,
                          editMode: _editMode,
                          showDragHandle: _editMode,
                          onRemove: () => _removeMetric(def.id),
                        ),
                      ),
                    ),
                  );
                }

                return ReorderableWrap(
                  spacing: gap,
                  runSpacing: gap,
                  enableReorder: _editMode,
                  needsLongPressDraggable: true,
                  onReorder: _onReorder,
                  children: children,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _headerControls(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      SizedBox(
        width: 160,
        height: kKpmToolbarHeight,
        child: DropdownButtonFormField<String>(
          key: ValueKey(_primaryPeriod),
          initialValue: _primaryPeriod,
          isExpanded: true,
          selectedItemBuilder: (context) => _primaryItems
              .map(
                (e) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(e.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            isDense: true,
            constraints: const BoxConstraints(minHeight: kKpmToolbarHeight),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          items: _primaryItems.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
          onChanged: _onPrimaryChanged,
        ),
      ),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(180, kKpmToolbarHeight),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () {},
        child: Text(
          reportGetDateRangeText(_primaryPeriod),
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'VS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ),
      SizedBox(
        width: 200,
        height: kKpmToolbarHeight,
        child: DropdownButtonFormField<String>(
          key: ValueKey(_comparisonPeriod),
          initialValue: _comparisonPeriod,
          isExpanded: true,
          selectedItemBuilder: (context) => _comparisonItems
              .map(
                (e) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(e.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            isDense: true,
            constraints: const BoxConstraints(minHeight: kKpmToolbarHeight),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          items: _comparisonItems.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: _onComparisonChanged,
        ),
      ),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(180, kKpmToolbarHeight),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () {},
        child: Text(
          reportGetComparisonDateRange(_comparisonPeriod, _primaryPeriod),
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      PopupMenuButton<String>(
        tooltip: 'More',
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(_editMode ? Icons.check : Icons.edit_outlined, size: 20),
              title: Text(_editMode ? 'Done' : 'Edit'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'add',
            child: ListTile(
              leading: Icon(Icons.add, size: 20),
              title: Text('Add'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
        onSelected: (v) {
          if (v == 'edit') setState(() => _editMode = !_editMode);
          if (v == 'add') _openAddDialog(context);
        },
        child: Container(
          height: 36,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.more_vert, size: 20),
        ),
      ),
    ];
  }

  Future<void> _openAddDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final available = kReportAvailableMetrics.where((m) => !_visibleMetricIds.contains(m.id)).toList();
        return AlertDialog(
          title: const Text('Add Metrics to Reports Overview'),
          content: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Click on any metric card below to add it to your reports overview',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth > 900 ? 4 : c.maxWidth > 500 ? 2 : 1;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 220,
                        ),
                        itemCount: available.length,
                        itemBuilder: (context, i) {
                          final m = available[i];
                          return _AddMetricTile(
                            def: m,
                            onAdd: () {
                              _addMetric(m.id);
                              Navigator.of(ctx).pop();
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ],
        );
      },
    );
  }
}

/// Primary period options — React [SelectContent] order.
const List<(String, String)> _primaryItems = [
  ('today', 'Today'),
  ('yesterday', 'Yesterday'),
  ('last-7-days', 'Last 7 days'),
  ('last-4-weeks', 'Last 4 weeks'),
  ('last-6-months', 'Last 6 months'),
  ('last-12-months', 'Last 12 months'),
  ('month-to-date', 'Month to date'),
  ('quarter-to-date', 'Quarter to date'),
  ('year-to-date', 'Year to date'),
  ('this-month', 'This Month'),
  ('last-month', 'Last Month'),
  ('this-quarter', 'This Quarter'),
  ('last-quarter', 'Last Quarter'),
  ('this-year', 'This Year'),
  ('last-year', 'Last Year'),
  ('all-time', 'All time'),
];

/// Comparison period — React list + hook defaults (`same-day-*`, `previous-*`).
const List<(String, String)> _comparisonItems = [
  ('same-day-last-week', 'Same day last week'),
  ('same-day-last-month', 'Same day last month'),
  ('same-day-last-year', 'Same day last year'),
  ('previous-period', 'Previous period'),
  ('previous-week', 'Previous week'),
  ('previous-month', 'Previous month'),
  ('previous-year', 'Previous year'),
  ('today', 'Today'),
  ('yesterday', 'Yesterday'),
  ('last-7-days', 'Last 7 days'),
  ('last-4-weeks', 'Last 4 weeks'),
  ('last-6-months', 'Last 6 months'),
  ('last-12-months', 'Last 12 months'),
  ('this-month', 'This Month'),
  ('last-month', 'Last Month'),
  ('this-quarter', 'This Quarter'),
  ('last-quarter', 'Last Quarter'),
  ('this-year', 'This Year'),
  ('last-year', 'Last Year'),
];

class _AddMetricTile extends StatelessWidget {
  const _AddMetricTile({required this.def, required this.onAdd});

  final ReportMetricDef def;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final rnd = Random(def.id.hashCode);
    final spots = List.generate(4, (j) => FlSpot(j.toDouble(), 300 + rnd.nextDouble() * 400));

    return Material(
      color: shell.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: shell.sidebarBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      def.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
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
                      '+0.00%',
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text('vs', style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.45))),
                  const SizedBox(width: 8),
                  Text(
                    def.valueType == ReportValueType.currency ? r'$0.00' : '0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                  ),
                ],
              ),
              Text(
                'Current vs Previous',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: const Color(0xFFE5911A),
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                            radius: 2,
                            color: const Color(0xFFE5911A),
                            strokeWidth: 1,
                            strokeColor: shell.cardBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
