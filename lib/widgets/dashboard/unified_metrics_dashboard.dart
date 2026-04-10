import 'dart:convert';
import 'dart:math';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/dashboard_prefs.dart';
import '../../theme/shell_theme.dart';
import 'metric_tab_contents.dart';
import 'metrics/detailed_metric_ui.dart';

/// Matches M3 [OutlinedButton] / dense inputs so the KPM filter strip aligns on one baseline.
const double kKpmToolbarHeight = 40;

class _MetricDef {
  const _MetricDef({
    required this.id,
    required this.title,
    required this.isCurrency,
    required this.color,
    required this.baseValue,
  });

  final String id;
  final String title;
  final bool isCurrency;
  final Color color;
  final double baseValue;
}

/// Key Performance Metrics block — parity with React [unified-metrics-dashboard.tsx].
class UnifiedMetricsDashboard extends StatefulWidget {
  const UnifiedMetricsDashboard({super.key});

  @override
  State<UnifiedMetricsDashboard> createState() => _UnifiedMetricsDashboardState();
}

class _UnifiedMetricsDashboardState extends State<UnifiedMetricsDashboard> with SingleTickerProviderStateMixin {
  static const _defs = <_MetricDef>[
    _MetricDef(id: 'net-sales', title: 'Net Sales', isCurrency: true, color: Color(0xFF22C55E), baseValue: 1414.18),
    _MetricDef(id: 'labor-cost', title: 'Labor Cost', isCurrency: true, color: Color(0xFFEF4444), baseValue: 890.25),
    _MetricDef(id: 'total-transactions', title: 'Total Transactions', isCurrency: false, color: Color(0xFF3B82F6), baseValue: 18),
    _MetricDef(id: 'customer-count', title: 'Customer Count', isCurrency: false, color: Color(0xFF06B6D4), baseValue: 156),
    _MetricDef(id: 'gross-sales', title: 'Gross Sales', isCurrency: true, color: Color(0xFF8B5CF6), baseValue: 1663.55),
    _MetricDef(id: 'food-cost', title: 'Food Cost', isCurrency: true, color: Color(0xFFF59E0B), baseValue: 445.80),
    _MetricDef(id: 'total-orders', title: 'Total Orders', isCurrency: false, color: Color(0xFF10B981), baseValue: 24),
    _MetricDef(id: 'average-order-value', title: 'Average Order Value', isCurrency: true, color: Color(0xFFF97316), baseValue: 69.31),
  ];

  String _primaryPeriod = 'today';
  String _comparisonPeriod = 'same-day-last-week';
  DateTimeRange? _primaryDateRange;
  DateTimeRange? _comparisonDateRange;
  bool _editMode = false;
  List<String> _visibleIds = const [
    'net-sales',
    'labor-cost',
    'total-transactions',
    'customer-count',
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final today = DateUtils.dateOnly(DateTime.now());
    _primaryDateRange = DateTimeRange(start: today, end: today);
    final cmp = today.subtract(const Duration(days: 7));
    _comparisonDateRange = DateTimeRange(start: cmp, end: cmp);
    _loadPrefs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUnifiedMetricsPrefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw);
      if (list is List && list.every((e) => e is String)) {
        setState(() => _visibleIds = List<String>.from(list));
      }
    } catch (_) {}
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUnifiedMetricsPrefsKey, jsonEncode(_visibleIds));
  }

  _MetricDef? _def(String id) {
    try {
      return _defs.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String _comparisonLabel() {
    switch (_comparisonPeriod) {
      case 'same-day-last-week':
        return 'same day last week';
      case 'same-day-last-month':
        return 'same day last month';
      case 'same-day-last-year':
        return 'same day last year';
      case 'previous-period':
        return 'previous period';
      case 'previous-week':
        return 'previous week';
      case 'previous-month':
        return 'previous month';
      default:
        return _comparisonPeriod.replaceAll('-', ' ');
    }
  }

  ({double current, double previous, bool positive}) _valuesFor(_MetricDef def) {
    final rangeKey = _primaryDateRange?.start.millisecondsSinceEpoch ?? 0;
    final r = Random(def.id.hashCode + _primaryPeriod.hashCode + rangeKey);
    final v = def.baseValue * (0.92 + r.nextDouble() * 0.16);
    final p = v * (0.85 + r.nextDouble() * 0.1);
    final labor = def.id == 'labor-cost';
    final delta = v - p;
    final positive = labor ? delta < 0 : delta > 0;
    return (current: v, previous: p, positive: positive);
  }

  List<FlSpot> _spots(Color c) {
    final r = Random(c.hashCode);
    return List.generate(
      5,
      (i) => FlSpot(i.toDouble(), 40 + r.nextDouble() * 55),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final id = _visibleIds.removeAt(oldIndex);
      _visibleIds.insert(newIndex, id);
    });
    _savePrefs();
  }

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final visible = _visibleIds.map(_def).whereType<_MetricDef>().toList();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 720;
                final lastSelectable = DateTime.now().add(const Duration(days: 365));
                final vsStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    );
                final controls = <Widget>[
                  _PeriodSelect(
                    value: _primaryPeriod,
                    onChanged: (v) => setState(() => _primaryPeriod = v),
                  ),
                  const SizedBox(width: 8),
                  _DateRangePopoverButton(
                    range: _primaryDateRange,
                    firstDate: DateTime(2020),
                    lastDate: lastSelectable,
                    onChanged: (r) => setState(() => _primaryDateRange = r),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: kKpmToolbarHeight,
                    child: Center(
                      child: Text('VS', style: vsStyle),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ComparisonSelect(
                    value: _comparisonPeriod,
                    onChanged: (v) => setState(() => _comparisonPeriod = v),
                  ),
                  const SizedBox(width: 8),
                  _DateRangePopoverButton(
                    range: _comparisonDateRange,
                    firstDate: DateTime(2020),
                    lastDate: lastSelectable,
                    onChanged: (r) => setState(() => _comparisonDateRange = r),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: kKpmToolbarHeight,
                    height: kKpmToolbarHeight,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      splashRadius: kKpmToolbarHeight / 2,
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (v) async {
                        if (v == 'edit') setState(() => _editMode = !_editMode);
                        if (v == 'add' && mounted) {
                          await showDialog<void>(
                            context: context,
                            builder: (ctx) => _AddMetricsDialog(
                              defs: _defs,
                              visibleIds: _visibleIds,
                              onAdd: (id) {
                                setState(() {
                                  if (!_visibleIds.contains(id)) {
                                    _visibleIds = [..._visibleIds, id];
                                  }
                                });
                                _savePrefs();
                                Navigator.of(ctx).pop();
                              },
                            ),
                          );
                        }
                      },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(_editMode ? 'Done' : 'Edit')),
                      const PopupMenuItem(value: 'add', child: Text('Add')),
                    ],
                    ),
                  ),
                ];
                const subtitleText =
                    'Comprehensive restaurant analytics with industry benchmarks and actionable insights';
                final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800);
                final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    );
                final subtitle = Text(subtitleText, style: subtitleStyle);
                // React: flex items-center justify-between on title row only; subtitle is full-width below (mt-2).
                Widget buildTitleRow({required bool oneLineFilters}) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Key Performance Metrics',
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (oneLineFilters)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: controls,
                        )
                      else
                        Flexible(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.end,
                            children: controls,
                          ),
                        ),
                    ],
                  );
                }
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Key Performance Metrics', style: titleStyle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: controls,
                      ),
                      const SizedBox(height: 8),
                      subtitle,
                    ],
                  );
                }
                final oneLineFilters = constraints.maxWidth >= 960;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitleRow(oneLineFilters: oneLineFilters),
                    const SizedBox(height: 8),
                    subtitle,
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, c) {
                final maxW = c.maxWidth;
                final tileW = maxW > 1200
                    ? (maxW - 48) / 4
                    : maxW > 700
                        ? (maxW - 24) / 2
                        : maxW;
                final children = visible.map((def) {
                  final vals = _valuesFor(def);
                  final pct = ((vals.current - vals.previous) / (vals.previous == 0 ? 1 : vals.previous)) * 100;
                  return KeyedSubtree(
                    key: ValueKey(def.id),
                    child: SizedBox(
                      width: tileW.clamp(200, 400),
                      child: _MetricCard(
                        def: def,
                        current: vals.current,
                        previous: vals.previous,
                        pct: pct,
                        positive: vals.positive,
                        comparisonLabel: _comparisonLabel(),
                        spots: _spots(def.color),
                        editMode: _editMode,
                        onRemove: () {
                          setState(() {
                            _visibleIds.remove(def.id);
                          });
                          _savePrefs();
                        },
                      ),
                    ),
                  );
                }).toList();

                return ReorderableWrap(
                  spacing: 16,
                  runSpacing: 16,
                  enableReorder: _editMode,
                  needsLongPressDraggable: true,
                  onReorder: _onReorder,
                  children: children,
                );
              },
            ),
            const SizedBox(height: 24),
            _sixStats(),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KpmSegmentedTabBar(
                  controller: _tabController,
                  labels: const [
                    'Sales & Revenue',
                    'Labor & Staffing',
                    'Items & Menu',
                    'Food Cost & COGS',
                    'Fixed Costs',
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    switch (_tabController.index) {
                      case 0:
                        return const SalesTabContent();
                      case 1:
                        return const LaborTabContent();
                      case 2:
                        return const ItemsTabContent();
                      case 3:
                        return const FoodCostTabContent();
                      case 4:
                      default:
                        return const FixedCostTabContent();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sixStats() {
    const stats = [
      ('Peak Hour', '6 PM'),
      ('Avg Labor %', '27%'),
      ('Total Hours', '163'),
      ('Efficiency', 'Good'),
      ('Target %', '25%'),
      ('Variance', '+2%'),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w > 900 ? 6 : 3;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          childAspectRatio: 2.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: stats
              .map(
                (s) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.$1, style: Theme.of(context).textTheme.bodySmall),
                    Text(s.$2, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Anchored date-range popover using [MenuAnchor] + [CalendarDatePicker2] (not modal `showDateRangePicker`).
class _DateRangePopoverButton extends StatelessWidget {
  const _DateRangePopoverButton({
    required this.range,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final DateTimeRange? range;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTimeRange?> onChanged;

  static List<DateTime?> _pickerValueFromRange(DateTimeRange? r) {
    if (r == null) return <DateTime?>[];
    return [DateUtils.dateOnly(r.start), DateUtils.dateOnly(r.end)];
  }

  String _label() {
    final r = range;
    if (r == null) return 'Pick a date range';
    final fmt = DateFormat('MMM dd, y');
    final a = fmt.format(r.start);
    final b = fmt.format(r.end);
    return '$a - $b';
  }

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.range,
      firstDate: DateUtils.dateOnly(firstDate),
      lastDate: DateUtils.dateOnly(lastDate),
      currentDate: DateUtils.dateOnly(DateTime.now()),
      centerAlignModePicker: true,
      selectedRangeHighlightColor: scheme.primary.withValues(alpha: 0.18),
      selectedDayHighlightColor: scheme.primary,
      daySplashColor: scheme.primary.withValues(alpha: 0.12),
    );

    return MenuAnchor(
      crossAxisUnconstrained: false,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(shell.popoverBackground),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.12)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: shell.sidebarBorder),
          ),
        ),
      ),
      menuChildren: [
        SizedBox(
          width: 336,
          height: 360,
          child: CalendarDatePicker2(
            config: config,
            value: _pickerValueFromRange(range),
            onValueChanged: (dates) {
              if (dates.isEmpty) return;
              if (dates.length == 1) {
                final d = DateUtils.dateOnly(dates.first);
                onChanged(DateTimeRange(start: d, end: d));
                return;
              }
              onChanged(
                DateTimeRange(
                  start: DateUtils.dateOnly(dates.first),
                  end: DateUtils.dateOnly(dates.last),
                ),
              );
            },
          ),
        ),
      ],
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, kKpmToolbarHeight),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
            _label(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

class _PeriodSelect extends StatelessWidget {
  const _PeriodSelect({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _opts = [
    ('today', 'Today'),
    ('yesterday', 'Yesterday'),
    ('last-7-days', 'Last 7 days'),
    ('this-week', 'This Week'),
    ('this-month', 'This Month'),
    ('last-month', 'Last Month'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: kKpmToolbarHeight,
      child: DropdownButtonFormField<String>(
        key: ValueKey(value),
        initialValue: value,
        decoration: InputDecoration(
          isDense: true,
          constraints: const BoxConstraints(minHeight: kKpmToolbarHeight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        items: _opts.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _ComparisonSelect extends StatelessWidget {
  const _ComparisonSelect({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _opts = [
    ('same-day-last-week', 'Same day last week'),
    ('same-day-last-month', 'Same day last month'),
    ('same-day-last-year', 'Same day last year'),
    ('previous-period', 'Previous period'),
    ('previous-week', 'Previous week'),
    ('previous-month', 'Previous month'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: kKpmToolbarHeight,
      child: DropdownButtonFormField<String>(
        key: ValueKey(value),
        initialValue: value,
        decoration: InputDecoration(
          isDense: true,
          constraints: const BoxConstraints(minHeight: kKpmToolbarHeight),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        items: _opts.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.def,
    required this.current,
    required this.previous,
    required this.pct,
    required this.positive,
    required this.comparisonLabel,
    required this.spots,
    required this.editMode,
    required this.onRemove,
  });

  final _MetricDef def;
  final double current;
  final double previous;
  final double pct;
  final bool positive;
  final String comparisonLabel;
  final List<FlSpot> spots;
  final bool editMode;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final fmt = NumberFormat.currency(symbol: r'$');
    final curStr = def.isCurrency ? fmt.format(current) : current.round().toString();
    final prevStr = def.isCurrency ? fmt.format(previous) : previous.round().toString();
    final pctStr = '${positive ? '+' : ''}${pct.toStringAsFixed(1)}%';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: shell.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: shell.sidebarBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(def.title, style: Theme.of(context).textTheme.bodySmall),
                      ),
                      Icon(Icons.info_outline, size: 16, color: Theme.of(context).disabledColor),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(curStr, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('vs $prevStr', style: Theme.of(context).textTheme.bodySmall),
                      TextButton(onPressed: () {}, child: const Text('View More')),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(positive ? Icons.north_east : Icons.south_east, size: 14, color: positive ? Colors.green : Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        pctStr,
                        style: TextStyle(color: positive ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'vs $comparisonLabel',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 88,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: def.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 18,
                        getTitlesWidget: (v, m) {
                          const labels = ['9a', '12p', '3p', '6p', '9p'];
                          final i = v.toInt().clamp(0, labels.length - 1);
                          return Text(labels[i], style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: def.color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: def.color.withValues(alpha: 0.22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (editMode)
          Positioned(
            right: -4,
            top: -4,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: EatOsShellTheme.of(context).destructive,
                foregroundColor: Colors.white,
                minimumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
              ),
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 16),
            ),
          ),
      ],
    );
  }
}

class _AddMetricsDialog extends StatelessWidget {
  const _AddMetricsDialog({
    required this.defs,
    required this.visibleIds,
    required this.onAdd,
  });

  final List<_MetricDef> defs;
  final List<String> visibleIds;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final available = defs.where((d) => !visibleIds.contains(d.id)).toList();
    return AlertDialog(
      title: const Text('Add Metrics to Dashboard'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Click a metric to add it to your dashboard',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: available
                    .map(
                      (d) => InkWell(
                        onTap: () => onAdd(d.id),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
