import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/dashboard_prefs.dart';
import '../../theme/shell_theme.dart';
import '../../utils/comparison_utils.dart';
import 'breakdown_metric_card.dart';
import 'breakdown_report_data.dart';
import 'unified_metrics_dashboard.dart' show kKpmToolbarHeight;

/// Parity with React [breakdown-report.tsx] + [usePersistentDateFilter] (`breakdown-report`).
class BreakdownReport extends StatefulWidget {
  const BreakdownReport({super.key});

  @override
  State<BreakdownReport> createState() => _BreakdownReportState();
}

class _BreakdownReportState extends State<BreakdownReport> {
  String _primaryPeriod = 'today';
  String _comparisonPeriod = 'same-day-last-week';
  List<String> _visibleMetricIds = List<String>.from(kDefaultVisibleBreakdownMetrics);
  bool _editMode = false;
  bool _loaded = false;

  static const List<(String, String)> _primaryItems = [
    ('today', 'Today'),
    ('yesterday', 'Yesterday'),
    ('last-7-days', 'Last 7 days'),
    ('this-week', 'This Week'),
    ('this-month', 'This Month'),
    ('last-month', 'Last Month'),
  ];

  static const List<(String, String)> _comparisonItems = [
    ('same-day-last-week', 'Same day last week'),
    ('same-day-last-month', 'Same day last month'),
    ('same-day-last-year', 'Same day last year'),
    ('previous-period', 'Previous period'),
    ('previous-week', 'Previous week'),
    ('previous-month', 'Previous month'),
    ('previous-year', 'Previous year'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getString('$kBreakdownReportStorageKey-primary');
    final c = prefs.getString('$kBreakdownReportStorageKey-comparison');
    final raw = prefs.getString(kBreakdownReportMetricsKey);
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
    await prefs.setString('$kBreakdownReportStorageKey-primary', _primaryPeriod);
    await prefs.setString('$kBreakdownReportStorageKey-comparison', _comparisonPeriod);
  }

  Future<void> _saveVisibleMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kBreakdownReportMetricsKey, jsonEncode(_visibleMetricIds));
  }

  void _onPrimaryChanged(String? v) {
    if (v == null) return;
    setState(() {
      _primaryPeriod = v;
      _comparisonPeriod = defaultComparisonForPrimaryBreakdown(v);
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

  CuDateRange _primaryRange() => getDateRangeForPeriod(_primaryPeriod);

  CuDateRange _comparisonRange() => getComparisonDateRange(_comparisonPeriod, _primaryRange());

  Future<void> _openAddDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final available = kAvailableBreakdownMetrics.where((m) => !_visibleMetricIds.contains(m.id)).toList();
        return AlertDialog(
          title: const Text('Add metrics to breakdown report'),
          content: SizedBox(
            width: 720,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Click a metric to add it to the report. Drag rows in edit mode to reorder.',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (available.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'All available metrics are already on this report.',
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                        ),
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, c) {
                        final cols = c.maxWidth > 640 ? 3 : c.maxWidth > 400 ? 2 : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 112,
                          ),
                          itemCount: available.length,
                          itemBuilder: (context, i) {
                            final m = available[i];
                            return Material(
                              color: EatOsShellTheme.of(context).cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  _addMetric(m.id);
                                  Navigator.of(ctx).pop();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: EatOsShellTheme.of(context).sidebarBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              m.title,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          ),
                                          Icon(
                                            Icons.info_outline,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      OutlinedButton(
                                        onPressed: () {
                                          _addMetric(m.id);
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add, size: 14),
                                            SizedBox(width: 4),
                                            Text('Add', style: TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

  List<Widget> _headerControls(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pr = _primaryRange();
    final cr = _comparisonRange();
    return [
      SizedBox(
        width: 128,
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
          minimumSize: const Size(160, kKpmToolbarHeight),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () {},
        child: Text(
          formatDateRange(pr),
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
        width: 192,
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
          items: _comparisonItems
              .map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: _onComparisonChanged,
        ),
      ),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(160, kKpmToolbarHeight),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: () {},
        child: Text(
          formatDateRange(cr),
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
              title: Text(_editMode ? 'Done' : 'Edit layout'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuItem(
            value: 'add',
            child: ListTile(
              leading: Icon(Icons.add, size: 20),
              title: Text('Add metrics'),
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
          height: kKpmToolbarHeight,
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

    final cmpLabel = breakdownShortComparisonLabel(_comparisonPeriod);
    final primaryRange = _primaryRange();
    final comparisonRange = _comparisonRange();

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
                final wide = c.maxWidth >= 900;
                final header = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Breakdown Report',
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
                      'Breakdown Report',
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
            const SizedBox(height: 8),
            Text(
              'Detailed breakdown of key metrics with visual comparison charts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
            ),
            const SizedBox(height: 24),
            if (_visibleMetricIds.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: shell.sidebarBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'No metrics selected.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openAddDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add metrics'),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, c) {
                  final maxW = c.maxWidth;
                  final twoCol = maxW >= 1024;
                  const gap = 24.0;
                  final tileW = twoCol ? (maxW - gap) / 2 : maxW;

                  final children = <Widget>[];
                  for (var i = 0; i < _visibleMetricIds.length; i++) {
                    final id = _visibleMetricIds[i];
                    final def = breakdownMetricById(id);
                    if (def == null) continue;
                    final data = generateComparisonData(
                      def.metricType,
                      primaryRange,
                      comparisonRange,
                      baseValue: def.baseValue,
                    );
                    final hourly = generateBreakdownHourlyPoints(def, data, _primaryPeriod, _comparisonPeriod);
                    children.add(
                      KeyedSubtree(
                        key: ValueKey(id),
                        child: SizedBox(
                          width: tileW,
                          child: BreakdownMetricCard(
                            metric: def,
                            comparisonData: data,
                            comparisonLabel: cmpLabel,
                            hourlyPoints: hourly,
                            editMode: _editMode,
                            showDragHandle: _editMode,
                            onRemove: _editMode ? () => _removeMetric(id) : null,
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
}
