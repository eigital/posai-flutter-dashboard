// Metric catalog + formatting — parity with [eatos-live-dashboard/src/components/breakdown-report.tsx].

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/comparison_utils.dart';

/// Default visible ids — React [breakdown-report.tsx] `useState` initializer.
const List<String> kDefaultVisibleBreakdownMetrics = [
  'net-sales',
  'labor-cost',
  'food-cost',
  'profit-margin',
];

enum BreakdownChartType { area, line }

/// Tailwind-style gradient stops (from-X-50 to-Y-50) approximated as [gradientLeft] → [gradientRight].
class BreakdownMetricDef {
  const BreakdownMetricDef({
    required this.id,
    required this.title,
    required this.metricType,
    required this.baseValue,
    required this.chartType,
    required this.gradientLeft,
    required this.gradientRight,
    required this.seriesColor,
  });

  final String id;
  final String title;

  /// `sales` | `orders` | `customers` | `cost` — matches React.
  final String metricType;
  final double baseValue;
  final BreakdownChartType chartType;
  final Color gradientLeft;
  final Color gradientRight;
  final Color seriesColor;
}

// --- Palette approximations (HSL stroke colors from React + Tailwind 50 stops) ---
const Color _gL = Color(0xFFF0FDF4);
const Color _gR = Color(0xFFECFDF5);
const Color _bL = Color(0xFFEFF6FF);
const Color _bR = Color(0xFFEEF2FF);
const Color _rL = Color(0xFFFEF2F2);
const Color _rR = Color(0xFFFDF2F8);
const Color _yL = Color(0xFFFEFCE8);
const Color _yR = Color(0xFFFFF7ED);
const Color _bcL = Color(0xFFEFF6FF);
const Color _bcR = Color(0xFFECFEFF);
const Color _etL = Color(0xFFECFDF5);
const Color _etR = Color(0xFFF0FDFA);
const Color _cbL = Color(0xFFECFEFF);
const Color _cbR = Color(0xFFEFF6FF);
const Color _orL = Color(0xFFFFF7ED);
const Color _orR = Color(0xFFFEF2F2);
const Color _piL = Color(0xFFF5F3FF);
const Color _piR = Color(0xFFEEF2FF);

const Color _stroke142 = Color(0xFF22C55E);
const Color _stroke221 = Color(0xFF2563EB);
const Color _stroke346 = Color(0xFFBE123C);
const Color _stroke45 = Color(0xFFEAB308);
const Color _stroke198 = Color(0xFF0EA5E9);
const Color _stroke158 = Color(0xFF34D399);
const Color _stroke32 = Color(0xFFD97706);
const Color _stroke262 = Color(0xFF9333EA);

/// All [availableBreakdownMetrics] from React (51 items).
const List<BreakdownMetricDef> kAvailableBreakdownMetrics = [
  // Sales
  BreakdownMetricDef(
    id: 'gross-sales',
    title: 'Gross Sales',
    metricType: 'sales',
    baseValue: 1663.55,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'net-sales',
    title: 'Net Sales',
    metricType: 'sales',
    baseValue: 1414.18,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'total-orders',
    title: 'Total Orders',
    metricType: 'orders',
    baseValue: 24,
    chartType: BreakdownChartType.line,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  BreakdownMetricDef(
    id: 'total-transactions',
    title: 'Total Transactions',
    metricType: 'orders',
    baseValue: 18,
    chartType: BreakdownChartType.line,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  BreakdownMetricDef(
    id: 'total-refunds',
    title: 'Total Refunds',
    metricType: 'cost',
    baseValue: 127.39,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'total-discounts',
    title: 'Total Discounts',
    metricType: 'cost',
    baseValue: 85.20,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'total-tax',
    title: 'Total Tax',
    metricType: 'sales',
    baseValue: 166.35,
    chartType: BreakdownChartType.area,
    gradientLeft: _yL,
    gradientRight: _yR,
    seriesColor: _stroke45,
  ),
  BreakdownMetricDef(
    id: 'total-tips',
    title: 'Total Tips',
    metricType: 'sales',
    baseValue: 245.80,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'total-delivery-fees',
    title: 'Total Delivery Fees',
    metricType: 'sales',
    baseValue: 45.00,
    chartType: BreakdownChartType.line,
    gradientLeft: _bcL,
    gradientRight: _bcR,
    seriesColor: _stroke198,
  ),
  BreakdownMetricDef(
    id: 'average-order-value',
    title: 'Average Order Value',
    metricType: 'sales',
    baseValue: 69.31,
    chartType: BreakdownChartType.area,
    gradientLeft: _etL,
    gradientRight: _etR,
    seriesColor: _stroke158,
  ),
  // Customer & traffic
  BreakdownMetricDef(
    id: 'customer-count',
    title: 'Customer Count',
    metricType: 'customers',
    baseValue: 156,
    chartType: BreakdownChartType.line,
    gradientLeft: _cbL,
    gradientRight: _cbR,
    seriesColor: _stroke198,
  ),
  BreakdownMetricDef(
    id: 'new-customers',
    title: 'New Customers',
    metricType: 'customers',
    baseValue: 45,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'returning-customers',
    title: 'Returning Customers',
    metricType: 'customers',
    baseValue: 111,
    chartType: BreakdownChartType.line,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  BreakdownMetricDef(
    id: 'items-sold',
    title: 'Items Sold',
    metricType: 'orders',
    baseValue: 89,
    chartType: BreakdownChartType.line,
    gradientLeft: _orL,
    gradientRight: _orR,
    seriesColor: _stroke32,
  ),
  BreakdownMetricDef(
    id: 'conversion-rate',
    title: 'Conversion Rate',
    metricType: 'customers',
    baseValue: 3.2,
    chartType: BreakdownChartType.area,
    gradientLeft: _etL,
    gradientRight: _etR,
    seriesColor: _stroke158,
  ),
  BreakdownMetricDef(
    id: 'return-rate',
    title: 'Return Rate',
    metricType: 'cost',
    baseValue: 2.1,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'customer-lifetime-value',
    title: 'Customer LTV',
    metricType: 'customers',
    baseValue: 285.40,
    chartType: BreakdownChartType.area,
    gradientLeft: _piL,
    gradientRight: _piR,
    seriesColor: _stroke262,
  ),
  // Payments
  BreakdownMetricDef(
    id: 'cash-payments',
    title: 'Cash Payments',
    metricType: 'sales',
    baseValue: 650.25,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'card-payments',
    title: 'Card Payments',
    metricType: 'sales',
    baseValue: 890.15,
    chartType: BreakdownChartType.area,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  BreakdownMetricDef(
    id: 'digital-payments',
    title: 'Digital Payments',
    metricType: 'sales',
    baseValue: 123.15,
    chartType: BreakdownChartType.line,
    gradientLeft: _cbL,
    gradientRight: _cbR,
    seriesColor: _stroke198,
  ),
  BreakdownMetricDef(
    id: 'failed-payments',
    title: 'Failed Payments',
    metricType: 'cost',
    baseValue: 3,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'disputed-payments',
    title: 'Disputed Payments',
    metricType: 'cost',
    baseValue: 1,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  // Product
  BreakdownMetricDef(
    id: 'top-products',
    title: 'Top Products',
    metricType: 'orders',
    baseValue: 12,
    chartType: BreakdownChartType.area,
    gradientLeft: _yL,
    gradientRight: _yR,
    seriesColor: _stroke45,
  ),
  BreakdownMetricDef(
    id: 'low-stock-items',
    title: 'Low Stock Items',
    metricType: 'cost',
    baseValue: 8,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'out-of-stock',
    title: 'Out of Stock',
    metricType: 'cost',
    baseValue: 2,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'product-views',
    title: 'Product Views',
    metricType: 'orders',
    baseValue: 1245,
    chartType: BreakdownChartType.area,
    gradientLeft: _bcL,
    gradientRight: _bcR,
    seriesColor: _stroke198,
  ),
  BreakdownMetricDef(
    id: 'cart-abandonment',
    title: 'Cart Abandonment',
    metricType: 'cost',
    baseValue: 23.5,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  // Time-based
  BreakdownMetricDef(
    id: 'daily-revenue',
    title: 'Daily Revenue',
    metricType: 'sales',
    baseValue: 456.78,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'weekly-growth',
    title: 'Weekly Growth',
    metricType: 'sales',
    baseValue: 8.2,
    chartType: BreakdownChartType.area,
    gradientLeft: _etL,
    gradientRight: _etR,
    seriesColor: _stroke158,
  ),
  BreakdownMetricDef(
    id: 'monthly-recurring',
    title: 'Monthly Recurring',
    metricType: 'sales',
    baseValue: 2340.50,
    chartType: BreakdownChartType.area,
    gradientLeft: _piL,
    gradientRight: _piR,
    seriesColor: _stroke262,
  ),
  // Operational
  BreakdownMetricDef(
    id: 'labor-cost',
    title: 'Labor Cost',
    metricType: 'cost',
    baseValue: 890.25,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
  BreakdownMetricDef(
    id: 'food-cost',
    title: 'Food Cost',
    metricType: 'cost',
    baseValue: 445.80,
    chartType: BreakdownChartType.line,
    gradientLeft: _yL,
    gradientRight: _yR,
    seriesColor: _stroke45,
  ),
  BreakdownMetricDef(
    id: 'overhead-cost',
    title: 'Overhead Cost',
    metricType: 'cost',
    baseValue: 234.50,
    chartType: BreakdownChartType.area,
    gradientLeft: _piL,
    gradientRight: _piR,
    seriesColor: _stroke262,
  ),
  BreakdownMetricDef(
    id: 'profit-margin',
    title: 'Profit Margin',
    metricType: 'sales',
    baseValue: 18.5,
    chartType: BreakdownChartType.area,
    gradientLeft: _etL,
    gradientRight: _etR,
    seriesColor: _stroke158,
  ),
  BreakdownMetricDef(
    id: 'break-even',
    title: 'Break Even',
    metricType: 'sales',
    baseValue: 1200.00,
    chartType: BreakdownChartType.line,
    gradientLeft: _orL,
    gradientRight: _orR,
    seriesColor: _stroke32,
  ),
  // Marketing
  BreakdownMetricDef(
    id: 'promotion-usage',
    title: 'Promotion Usage',
    metricType: 'orders',
    baseValue: 34,
    chartType: BreakdownChartType.line,
    gradientLeft: _yL,
    gradientRight: _yR,
    seriesColor: _stroke45,
  ),
  BreakdownMetricDef(
    id: 'loyalty-points',
    title: 'Loyalty Points Used',
    metricType: 'customers',
    baseValue: 1250,
    chartType: BreakdownChartType.area,
    gradientLeft: _cbL,
    gradientRight: _cbR,
    seriesColor: _stroke198,
  ),
  BreakdownMetricDef(
    id: 'referral-revenue',
    title: 'Referral Revenue',
    metricType: 'sales',
    baseValue: 178.90,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'social-media-orders',
    title: 'Social Media Orders',
    metricType: 'orders',
    baseValue: 12,
    chartType: BreakdownChartType.line,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  // Geographic
  BreakdownMetricDef(
    id: 'local-orders',
    title: 'Local Orders',
    metricType: 'orders',
    baseValue: 78,
    chartType: BreakdownChartType.area,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  BreakdownMetricDef(
    id: 'delivery-orders',
    title: 'Delivery Orders',
    metricType: 'orders',
    baseValue: 56,
    chartType: BreakdownChartType.line,
    gradientLeft: _cbL,
    gradientRight: _cbR,
    seriesColor: _stroke198,
  ),
  BreakdownMetricDef(
    id: 'pickup-orders',
    title: 'Pickup Orders',
    metricType: 'orders',
    baseValue: 34,
    chartType: BreakdownChartType.line,
    gradientLeft: _orL,
    gradientRight: _orR,
    seriesColor: _stroke32,
  ),
  BreakdownMetricDef(
    id: 'dine-in-orders',
    title: 'Dine-in Orders',
    metricType: 'orders',
    baseValue: 67,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  // Quality
  BreakdownMetricDef(
    id: 'customer-satisfaction',
    title: 'Customer Satisfaction',
    metricType: 'customers',
    baseValue: 4.6,
    chartType: BreakdownChartType.area,
    gradientLeft: _etL,
    gradientRight: _etR,
    seriesColor: _stroke158,
  ),
  BreakdownMetricDef(
    id: 'order-accuracy',
    title: 'Order Accuracy',
    metricType: 'orders',
    baseValue: 96.8,
    chartType: BreakdownChartType.area,
    gradientLeft: _gL,
    gradientRight: _gR,
    seriesColor: _stroke142,
  ),
  BreakdownMetricDef(
    id: 'service-rating',
    title: 'Service Rating',
    metricType: 'customers',
    baseValue: 4.5,
    chartType: BreakdownChartType.area,
    gradientLeft: _bL,
    gradientRight: _bR,
    seriesColor: _stroke221,
  ),
  BreakdownMetricDef(
    id: 'complaint-rate',
    title: 'Complaint Rate',
    metricType: 'cost',
    baseValue: 1.2,
    chartType: BreakdownChartType.line,
    gradientLeft: _rL,
    gradientRight: _rR,
    seriesColor: _stroke346,
  ),
];

BreakdownMetricDef? breakdownMetricById(String id) {
  for (final m in kAvailableBreakdownMetrics) {
    if (m.id == id) return m;
  }
  return null;
}

final _currencyFmt = NumberFormat.currency(locale: 'en_US', symbol: r'$');

/// Parity with TS `formatValue` inside [BreakdownMetricCard].
String formatBreakdownValue(BreakdownMetricDef metric, double value) {
  final id = metric.id;
  if (id == 'profit-margin' ||
      id == 'conversion-rate' ||
      id == 'return-rate' ||
      id == 'weekly-growth' ||
      id == 'cart-abandonment' ||
      id == 'order-accuracy') {
    return '${value.toStringAsFixed(1)}%';
  }
  if (id == 'customer-satisfaction' || id == 'service-rating') {
    return '${value.toStringAsFixed(1)}/5';
  }
  if (id == 'cost-vs-revenue') {
    return '${value.toStringAsFixed(1)}:1';
  }
  if (id == 'peak-hours') return '12-2 PM';
  if (id == 'delivery-time') return '28 min';
  if (metric.metricType == 'cost' || metric.metricType == 'sales') {
    return _currencyFmt.format(value);
  }
  return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
}

/// Metrics where an increase is "bad" — React `negativeMetrics`.
const Set<String> kBreakdownNegativeMetricIds = {
  'total-refunds',
  'total-discounts',
  'labor-cost',
  'food-cost',
  'overhead-cost',
  'failed-payments',
  'disputed-payments',
  'low-stock-items',
  'out-of-stock',
  'cart-abandonment',
  'return-rate',
  'complaint-rate',
};

class BreakdownBadgeStyle {
  const BreakdownBadgeStyle({required this.text, required this.background, required this.foreground});

  final String text;
  final Color background;
  final Color foreground;
}

BreakdownBadgeStyle breakdownBadgeStyle(BreakdownMetricDef metric, CuComparisonData data) {
  if (metric.id == 'cost-vs-revenue') {
    return const BreakdownBadgeStyle(
      text: 'Balanced',
      background: Color(0xFFFFEDD5),
      foreground: Color(0xFFC2410C),
    );
  }
  final negative = kBreakdownNegativeMetricIds.contains(metric.id);
  final actuallyGood = negative ? !data.isPositive : data.isPositive;
  final sign = data.percentage >= 0 ? '+' : '';
  final text = '$sign${data.percentage.toStringAsFixed(1)}%';
  if (actuallyGood) {
    return BreakdownBadgeStyle(
      text: text,
      background: const Color(0xFFF0FDF4),
      foreground: const Color(0xFF15803D),
    );
  }
  return BreakdownBadgeStyle(
    text: text,
    background: const Color(0xFFFEF2F2),
    foreground: const Color(0xFFB91C1C),
  );
}

/// React [getComparisonLabel].
String breakdownShortComparisonLabel(String comparisonPeriod) {
  switch (comparisonPeriod) {
    case 'same-day-last-week':
      return 'vs same day last week';
    case 'same-day-last-month':
      return 'vs same day last month';
    case 'same-day-last-year':
      return 'vs same day last year';
    case 'previous-period':
      return 'vs previous period';
    case 'previous-week':
      return 'vs previous week';
    case 'previous-month':
      return 'vs previous month';
    case 'previous-year':
      return 'vs previous year';
    default:
      return 'vs ${comparisonPeriod.replaceAll('-', ' ')}';
  }
}

class BreakdownHourPoint {
  const BreakdownHourPoint({required this.time, required this.current, required this.previous});

  final String time;
  final double current;
  final double previous;
}

/// Seeded hourly series — parity with React `generateChartData` (deterministic).
List<BreakdownHourPoint> generateBreakdownHourlyPoints(
  BreakdownMetricDef metric,
  CuComparisonData cmp,
  String primaryPeriod,
  String comparisonPeriod,
) {
  const times = ['6AM', '9AM', '12PM', '3PM', '6PM', '9PM'];
  final rnd = Random(Object.hash(metric.id, primaryPeriod, comparisonPeriod));
  return times
      .map((t) {
        final cur =
            ((cmp.currentValue / 6) * (0.8 + rnd.nextDouble() * 0.4) * 100).round() / 100;
        final prev =
            ((cmp.previousValue / 6) * (0.8 + rnd.nextDouble() * 0.4) * 100).round() / 100;
        return BreakdownHourPoint(time: t, current: cur, previous: prev);
      })
      .toList();
}

/// React `routes` map → [kShellPlaceholderPaths] analogues (View more navigates only when non-null).
String? breakdownViewMoreRoute(String metricId) {
  switch (metricId) {
    case 'labor-cost':
      return '/workforce';
    case 'net-sales':
      return '/sales';
    case 'delivery-orders':
      return '/online-ordering';
    case 'dine-in-orders':
      return '/sales';
    case 'food-cost':
      return '/menu';
    case 'profit-margin':
      return '/analytics';
    case 'customer-satisfaction':
      return '/guests';
    case 'average-order-value':
      return '/sales';
    default:
      return null;
  }
}
