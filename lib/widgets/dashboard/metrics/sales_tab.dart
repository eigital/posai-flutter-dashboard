import 'package:flutter/material.dart';

import '../../../theme/shell_theme.dart';
import 'csv_export.dart';
import 'detailed_metric_ui.dart';
import 'kpi_formatting.dart';
import 'restaurant_kpi_data.dart';

class SalesTabContent extends StatefulWidget {
  const SalesTabContent({super.key});

  @override
  State<SalesTabContent> createState() => _SalesTabContentState();
}

class _SalesTabContentState extends State<SalesTabContent> {
  final _kpi = kRestaurantKpis.sales;

  static const _cols = ['title', 'value', 'change', 'description'];

  @override
  Widget build(BuildContext context) {
    final d = _kpi;
    final netSalesChange = calculatePercentageChange(d.netSales, d.previousPeriod.netSales);
    final aovChange = calculatePercentageChange(d.averageOrderValue, d.previousPeriod.averageOrderValue);
    final customerChange = calculatePercentageChange(d.customerCount.toDouble(), d.previousPeriod.customerCount.toDouble());
    final grossChange = ((d.grossSales - d.previousPeriod.grossSales) / d.previousPeriod.grossSales) * 100;

    final metrics = <_SaleMetric>[
      _SaleMetric(
        title: 'Net Sales',
        value: formatCurrency(d.netSales),
        change: netSalesChange,
        icon: Icons.attach_money,
        description: 'Total revenue after discounts and refunds',
      ),
      _SaleMetric(
        title: 'Gross Sales',
        value: formatCurrency(d.grossSales),
        change: grossChange,
        icon: Icons.trending_up,
        description: 'Total revenue before adjustments',
      ),
      _SaleMetric(
        title: 'Average Order Value',
        value: formatCurrency(d.averageOrderValue),
        change: aovChange,
        icon: Icons.shopping_cart_outlined,
        description: 'Average amount spent per order',
      ),
      _SaleMetric(
        title: 'Customer Count',
        value: d.customerCount.toString(),
        change: customerChange,
        icon: Icons.people_outline,
        description: 'Total number of unique customers served',
      ),
      _SaleMetric(
        title: 'Sales per Sq Ft',
        value: formatCurrency(d.salesPerSquareFoot),
        change: 5.2,
        icon: Icons.calculate_outlined,
        description: 'Revenue efficiency per square foot',
      ),
      _SaleMetric(
        title: 'Revenue per Available Seat Hour',
        value: formatCurrency(d.revenuePASH),
        change: 3.8,
        icon: Icons.trending_up,
        description: 'Revenue optimization metric for seating efficiency',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => _openExport(context, metrics),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Export'),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth >= 1024 ? 3 : (c.maxWidth >= 768 ? 2 : 1);
            const gap = 16.0;
            final itemW = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: metrics
                  .map(
                    (m) => SizedBox(
                      width: itemW,
                      child: DetailedMetricCard(
                        title: m.title,
                        icon: m.icon,
                        value: m.value,
                        trendUp: m.change > 0,
                        badgeLabel: m.change > 0 ? '+${formatPercentage(m.change)}' : formatPercentage(m.change),
                        badgeStyle: m.change > 0 ? KpiChipStyle.success : KpiChipStyle.destructive,
                        description: m.description,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            final twoCol = c.maxWidth >= 1024;
            final row = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _revenueTrendsCard(context, netSalesChange, customerChange, aovChange)),
                const SizedBox(width: 12),
                Expanded(child: _actionItemsCard(context)),
              ],
            );
            final col = Column(
              children: [
                _revenueTrendsCard(context, netSalesChange, customerChange, aovChange),
                const SizedBox(height: 12),
                _actionItemsCard(context),
              ],
            );
            return twoCol ? row : col;
          },
        ),
      ],
    );
  }

  Widget _revenueTrendsCard(BuildContext context, double netSalesChange, double customerChange, double aovChange) {
    final shell = EatOsShellTheme.of(context);
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Trends', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniTrend('Net Sales', '+${formatPercentage(netSalesChange)}', shell.success, context),
              ),
              Expanded(
                child: _miniTrend('Customers', '+${formatPercentage(customerChange)}', shell.success, context),
              ),
              Expanded(
                child: _miniTrend('AOV', '+${formatPercentage(aovChange)}', shell.success, context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniTrend(String label, String pct, Color color, BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(pct, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _actionItemsCard(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Action Items', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionPill(context, 'Strong Performance', shell.success, 0.05, 0.2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionPill(context, 'Focus AOV', w, 0.05, 0.2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionPillAccent(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionPill(BuildContext context, String text, Color c, double bgA, double borderA) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: bgA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: borderA)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }

  Widget _actionPillAccent(BuildContext context) {
    final shell = EatOsShellTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: shell.sidebarAccent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: shell.sidebarBorder),
      ),
      child: Text(
        'Upselling',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: shell.sidebarForeground),
      ),
    );
  }

  Future<void> _openExport(BuildContext context, List<_SaleMetric> metrics) async {
    var selected = List<String>.from(_cols);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Export Sales Metrics'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select the columns you want to include in your export:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      ('title', 'Metric Name'),
                      ('value', 'Value'),
                      ('change', 'Change %'),
                      ('description', 'Description'),
                    ].map((e) {
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(e.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        value: selected.contains(e.$1),
                        onChanged: (v) {
                          setLocal(() {
                            if (v == true) {
                              if (!selected.contains(e.$1)) selected = [...selected, e.$1];
                            } else {
                              selected = selected.where((x) => x != e.$1).toList();
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          _exportCsv(metrics, selected);
                          Navigator.pop(ctx);
                        },
                  child: const Text('Export CSV'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _exportCsv(List<_SaleMetric> metrics, List<String> cols) {
    final headers = cols.map((c) {
      switch (c) {
        case 'title':
          return 'Metric Name';
        case 'value':
          return 'Value';
        case 'change':
          return 'Change %';
        case 'description':
          return 'Description';
        default:
          return c;
      }
    }).join(',');

    final lines = metrics.map((m) {
      return cols.map((c) {
        switch (c) {
          case 'title':
            return m.title;
          case 'value':
            return m.value;
          case 'change':
            final sign = m.change > 0 ? '+' : '';
            return '$sign${formatPercentage(m.change)}';
          case 'description':
            return '"${m.description}"';
          default:
            return '';
        }
      }).join(',');
    }).join('\n');

    final csv = '$headers\n$lines';
    downloadCsv(csv, 'sales-metrics.csv');
  }
}

class _SaleMetric {
  const _SaleMetric({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.description,
  });

  final String title;
  final String value;
  final double change;
  final IconData icon;
  final String description;
}
