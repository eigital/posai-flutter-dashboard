import 'package:flutter/material.dart';

import '../../../theme/shell_theme.dart';
import 'detailed_metric_ui.dart';
import 'kpi_formatting.dart';
import 'restaurant_kpi_data.dart';

class ItemsTabContent extends StatelessWidget {
  const ItemsTabContent({super.key});

  IconData _classIcon(MenuItemClassification c) {
    switch (c) {
      case MenuItemClassification.star:
        return Icons.star;
      case MenuItemClassification.plowHorse:
        return Icons.bolt;
      case MenuItemClassification.puzzle:
        return Icons.error_outline;
      case MenuItemClassification.dog:
        return Icons.gps_fixed;
    }
  }

  Color _classColor(MenuItemClassification c) {
    switch (c) {
      case MenuItemClassification.star:
        return const Color(0xFFEAB308);
      case MenuItemClassification.plowHorse:
        return const Color(0xFF3B82F6);
      case MenuItemClassification.puzzle:
        return const Color(0xFFF97316);
      case MenuItemClassification.dog:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = kRestaurantKpis.items;
    final me = data.menuEngineering;

    Widget quadrant(String title, IconData icon, Color iconColor, List<MenuItemData> items, String blurb) {
      return DetailShellCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Icon(icon, size: 16, color: iconColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${items.length}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(blurb, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
            const SizedBox(height: 8),
            ...items.take(3).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${e.name} - ${formatPercentage(e.profitMargin)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
                    ),
                  ),
                ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final four = c.maxWidth >= 1024;
            final two = c.maxWidth >= 640;
            final cols = four ? 4 : (two ? 2 : 1);
            const gap = 16.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(width: w, child: quadrant('Stars', Icons.star, const Color(0xFFEAB308), me.stars, 'High profit, high popularity')),
                SizedBox(width: w, child: quadrant('Plow Horses', Icons.flash_on, const Color(0xFF3B82F6), me.plowHorses, 'Low profit, high popularity')),
                SizedBox(width: w, child: quadrant('Puzzles', Icons.error_outline, const Color(0xFFF97316), me.puzzles, 'High profit, low popularity')),
                SizedBox(width: w, child: quadrant('Dogs', Icons.gps_fixed, const Color(0xFFEF4444), me.dogs, 'Low profit, low popularity')),
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
                  Expanded(child: _itemsTableCard(context, 'Best Selling Items', data.bestSellingItems, Icons.trending_up, EatOsShellTheme.of(context).success)),
                  const SizedBox(width: 16),
                  Expanded(child: _itemsTableCard(context, 'Worst Selling Items', data.worstSellingItems, Icons.trending_down, EatOsShellTheme.of(context).destructive)),
                ],
              );
            }
            return Column(
              children: [
                _itemsTableCard(context, 'Best Selling Items', data.bestSellingItems, Icons.trending_up, EatOsShellTheme.of(context).success),
                const SizedBox(height: 16),
                _itemsTableCard(context, 'Worst Selling Items', data.worstSellingItems, Icons.trending_down, EatOsShellTheme.of(context).destructive),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _categoryPerformanceCard(context, data),
      ],
    );
  }

  Widget _itemsTableCard(BuildContext context, String title, List<MenuItemData> rows, IconData headIcon, Color headColor) {
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(headIcon, size: 22, color: headColor),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 40,
              columns: const [
                DataColumn(label: Text('Item')),
                DataColumn(label: Text('Units Sold'), numeric: true),
                DataColumn(label: Text('Revenue'), numeric: true),
                DataColumn(label: Text('Margin'), numeric: true),
              ],
              rows: rows
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              Icon(_classIcon(item.classification), size: 18, color: _classColor(item.classification)),
                              const SizedBox(width: 8),
                              Text(item.name),
                            ],
                          ),
                        ),
                        DataCell(Text('${item.unitsSold}', textAlign: TextAlign.right)),
                        DataCell(Text(formatCurrency(item.revenue), textAlign: TextAlign.right)),
                        DataCell(Text(formatPercentage(item.profitMargin), textAlign: TextAlign.right)),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryPerformanceCard(BuildContext context, ItemsMetricsData data) {
    final shell = EatOsShellTheme.of(context);
    final w = kWarningColor(context);
    final mix = data.categoryMix.entries.take(4).toList();
    return DetailShellCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Performance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text('Category Performance', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 8),
          Row(
            children: mix
                .map(
                  (e) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: shell.mutedSolid.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Text(e.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(formatPercentage(e.value), style: const TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Menu Engineering Actions', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (data.menuEngineering.dogs.isNotEmpty)
                _engAction(context, 'Remove ${data.menuEngineering.dogs.length} Dogs', shell.destructive),
              if (data.menuEngineering.puzzles.isNotEmpty)
                _engAction(context, 'Promote ${data.menuEngineering.puzzles.length} Puzzles', w),
              _engAction(context, 'Feature ${data.menuEngineering.stars.length} Stars', shell.success),
              _engAction(context, 'Avg: ${formatPercentage(data.averageItemProfitMargin)}', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _engAction(BuildContext context, String text, Color? c) {
    final shell = EatOsShellTheme.of(context);
    if (c != null) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: shell.sidebarAccent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: shell.sidebarBorder),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: shell.sidebarForeground)),
    );
  }
}
