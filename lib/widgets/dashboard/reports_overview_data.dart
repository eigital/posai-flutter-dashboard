// Data and helpers ported from [eatos-live-dashboard/src/components/reports-overview.tsx].

import 'dart:math';

import 'package:intl/intl.dart';

/// Mirrors React `valueType: 'currency' | 'number'`.
enum ReportValueType {
  currency,
  number,
}

class ReportMetricDef {
  const ReportMetricDef({
    required this.id,
    required this.title,
    required this.value,
    required this.valueType,
  });

  final String id;
  final String title;
  final String value;
  final ReportValueType valueType;
}

class ReportChartPoint {
  const ReportChartPoint({
    required this.idx,
    required this.value,
    required this.previousValue,
    required this.date,
    required this.previousDate,
  });

  final int idx;
  final double value;
  final double previousValue;
  final String date;
  final String previousDate;
}

class ReportMetricDetails {
  const ReportMetricDetails({
    required this.comparison,
    required this.change,
    required this.period,
    required this.baseValue,
    required this.dateRangeStart,
    required this.dateRangeEnd,
  });

  final String comparison;
  final String change;
  final String period;
  final double baseValue;
  final String dateRangeStart;
  final String dateRangeEnd;
}

class ReportYAxisConfig {
  const ReportYAxisConfig({required this.minY, required this.maxY, required this.ticks});

  final double minY;
  final double maxY;
  final List<double> ticks;
}

final _currencyFmt = NumberFormat.currency(locale: 'en_US', symbol: r'$');
final _integerFmt = NumberFormat('#,##0', 'en_US');

String formatReportValue(double value, ReportValueType valueType) {
  if (valueType == ReportValueType.currency) {
    return _currencyFmt.format(value);
  }
  return _integerFmt.format(value.round());
}

/// Same keys as React [getMetricDetails] (subset with rich data; default fallback for others).
ReportMetricDetails getReportMetricDetails(String metricId) {
  const map = <String, ReportMetricDetails>{
    'gross-sales': ReportMetricDetails(
      comparison: r'$1,414.18',
      change: '-77.2%',
      period: 'previous year',
      baseValue: 1664,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'net-sales': ReportMetricDetails(
      comparison: r'$1,200.15',
      change: '+12.3%',
      period: 'previous year',
      baseValue: 1414,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'total-orders': ReportMetricDetails(
      comparison: '18',
      change: '+33.3%',
      period: 'previous period',
      baseValue: 24,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'total-transactions': ReportMetricDetails(
      comparison: '15',
      change: '+20.0%',
      period: 'previous period',
      baseValue: 18,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'total-refunds': ReportMetricDetails(
      comparison: r'$89.25',
      change: '+43.2%',
      period: 'previous period',
      baseValue: 127,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'total-discounts': ReportMetricDetails(
      comparison: r'$67.50',
      change: '+26.2%',
      period: 'previous period',
      baseValue: 85,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'total-tax': ReportMetricDetails(
      comparison: r'$142.80',
      change: '+16.4%',
      period: 'previous period',
      baseValue: 166,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
    'total-tips': ReportMetricDetails(
      comparison: r'$198.65',
      change: '+23.7%',
      period: 'previous period',
      baseValue: 245,
      dateRangeStart: 'Aug 10, 2025',
      dateRangeEnd: 'Aug 31, 2025',
    ),
  };
  return map[metricId] ??
      const ReportMetricDetails(
        comparison: r'$0.00',
        change: '+0.0%',
        period: 'previous period',
        baseValue: 100,
        dateRangeStart: 'Aug 10, 2025',
        dateRangeEnd: 'Aug 31, 2025',
      );
}

List<ReportChartPoint> generateReportChartData(
  String metricId,
  double baseValue,
  ReportValueType valueType,
  String comparisonPeriod,
) {
  final variance = baseValue * 0.3;
  final rnd = Random(metricId.hashCode);
  double toCurrencyOrInt(double n) =>
      valueType == ReportValueType.currency ? (n * 100).round() / 100 : n.roundToDouble();

  final out = <ReportChartPoint>[];
  for (var i = 0; i < 6; i++) {
    final currentVariation = (rnd.nextDouble() - 0.5) * variance;
    final previousVariation = (rnd.nextDouble() - 0.5) * variance;
    var current = max(0.0, baseValue + currentVariation);
    var previous = max(0.0, baseValue * 0.8 + previousVariation);
    current = toCurrencyOrInt(current);
    previous = toCurrencyOrInt(previous);

    final day = 10 + i * 4;
    final currentDt = DateTime(2025, 8, day);
    final currentDate = DateFormat('MMM d, y').format(currentDt);
    final prevDate = comparisonPeriod.contains('year')
        ? DateFormat('MMM d, y').format(DateTime(2024, currentDt.month, currentDt.day))
        : DateFormat('MMM d, y').format(currentDt.subtract(const Duration(days: 28)));

    out.add(
      ReportChartPoint(
        idx: i,
        value: current,
        previousValue: previous,
        date: currentDate,
        previousDate: prevDate,
      ),
    );
  }
  return out;
}

ReportYAxisConfig getReportYAxisConfig(List<ReportChartPoint> data, ReportValueType valueType) {
  final all = <double>[];
  for (final d in data) {
    all.add(d.value);
    all.add(d.previousValue);
  }
  var maxValue = all.isEmpty ? 0.0 : all.reduce(max);
  if (maxValue <= 0) maxValue = 1;

  if (valueType == ReportValueType.currency) {
    final mid = (maxValue / 2 * 100).round() / 100;
    return ReportYAxisConfig(minY: 0, maxY: maxValue, ticks: [0, mid, maxValue]);
  }
  final maxInt = maxValue.round();
  final mid = (maxInt / 2).round();
  return ReportYAxisConfig(minY: 0, maxY: maxInt.toDouble(), ticks: [0, mid.toDouble(), maxInt.toDouble()]);
}

/// Primary period button label — matches React `getDateRangeText`.
String reportGetDateRangeText(String period) {
  switch (period) {
    case 'today':
      return 'Sep 1st 2025';
    case 'yesterday':
      return 'Aug 31st 2025';
    case 'last-7-days':
      return 'Aug 25th 2025 - Sep 1st 2025';
    case 'last-4-weeks':
      return 'Aug 4th 2025 - Sep 1st 2025';
    case 'last-6-months':
      return 'Mar 1st 2025 - Sep 1st 2025';
    case 'last-12-months':
      return 'Sep 1st 2024 - Sep 1st 2025';
    case 'month-to-date':
      return 'Sep 1st 2025 - Sep 1st 2025';
    case 'quarter-to-date':
      return 'Jul 1st 2025 - Sep 1st 2025';
    case 'year-to-date':
      return 'Jan 1st 2025 - Sep 1st 2025';
    case 'this-quarter':
      return 'Jul 1st 2025 - Sep 30th 2025';
    case 'last-quarter':
      return 'Apr 1st 2025 - Jun 30th 2025';
    case 'this-month':
      return 'Sep 1st 2025 - Sep 30th 2025';
    case 'last-month':
      return 'Aug 1st 2025 - Aug 31st 2025';
    case 'this-year':
      return 'Jan 1st 2025 - Dec 31st 2025';
    case 'last-year':
      return 'Jan 1st 2024 - Dec 31st 2024';
    case 'all-time':
      return 'All Time';
    default:
      return 'Jul 1st 2025 - Sep 30th 2025';
  }
}

/// Matches React `getComparisonDateRange(comparison, primary)`.
String reportGetComparisonDateRange(String comparison, String primary) {
  if (comparison == 'previous-period') {
    switch (primary) {
      case 'this-quarter':
        return 'Apr 1st 2025 - Jun 30th 2025';
      case 'last-quarter':
        return 'Jan 1st 2025 - Mar 31st 2025';
      case 'this-month':
        return 'Aug 1st 2025 - Aug 31st 2025';
      case 'last-month':
        return 'Jul 1st 2025 - Jul 31st 2025';
      case 'today':
        return 'Aug 31st 2025';
      case 'yesterday':
        return 'Aug 30th 2025';
      case 'last-7-days':
        return 'Aug 18th 2025 - Aug 24th 2025';
      case 'this-year':
        return 'Jan 1st 2024 - Dec 31st 2024';
      default:
        return 'Apr 1st 2025 - Jun 30th 2025';
    }
  }
  return reportGetDateRangeText(comparison);
}

/// Smart comparison default when primary changes — [usePersistentDateFilter] `handlePrimaryPeriodChange`.
String reportDefaultComparisonForPrimary(String primary) {
  switch (primary) {
    case 'today':
    case 'yesterday':
      return 'same-day-last-week';
    case 'last-7-days':
    case 'this-week':
      return 'previous-week';
    case 'this-month':
    case 'last-month':
      return 'previous-month';
    case 'this-year':
      return 'previous-year';
    default:
      return 'previous-period';
  }
}

/// `availableMetrics` from React (id, title, display value, type).
const List<ReportMetricDef> kReportAvailableMetrics = [
  ReportMetricDef(id: 'gross-sales', title: 'Gross Sales', value: r'$1,663.55', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'net-sales', title: 'Net Sales', value: r'$1,414.18', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'total-orders', title: 'Total Orders', value: '24', valueType: ReportValueType.number),
  ReportMetricDef(id: 'total-transactions', title: 'Total Transactions', value: '18', valueType: ReportValueType.number),
  ReportMetricDef(id: 'total-refunds', title: 'Total Refunds', value: r'$127.39', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'total-discounts', title: 'Total Discounts', value: r'$85.20', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'total-tax', title: 'Total Tax', value: r'$166.35', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'total-tips', title: 'Total Tips', value: r'$245.80', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'total-delivery-fees', title: 'Total Delivery Fees', value: r'$45.00', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'average-order-value', title: 'Average Order Value', value: r'$69.31', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'customer-count', title: 'Customer Count', value: '156', valueType: ReportValueType.number),
  ReportMetricDef(id: 'new-customers', title: 'New Customers', value: '45', valueType: ReportValueType.number),
  ReportMetricDef(id: 'returning-customers', title: 'Returning Customers', value: '111', valueType: ReportValueType.number),
  ReportMetricDef(id: 'items-sold', title: 'Items Sold', value: '89', valueType: ReportValueType.number),
  ReportMetricDef(id: 'conversion-rate', title: 'Conversion Rate', value: '3.2%', valueType: ReportValueType.number),
  ReportMetricDef(id: 'return-rate', title: 'Return Rate', value: '2.1%', valueType: ReportValueType.number),
  ReportMetricDef(id: 'customer-lifetime-value', title: 'Customer LTV', value: r'$285.40', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'cash-payments', title: 'Cash Payments', value: r'$650.25', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'card-payments', title: 'Card Payments', value: r'$890.15', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'digital-payments', title: 'Digital Payments', value: r'$123.15', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'failed-payments', title: 'Failed Payments', value: '3', valueType: ReportValueType.number),
  ReportMetricDef(id: 'disputed-payments', title: 'Disputed Payments', value: '1', valueType: ReportValueType.number),
  ReportMetricDef(id: 'top-products', title: 'Top Products', value: '12', valueType: ReportValueType.number),
  ReportMetricDef(id: 'low-stock-items', title: 'Low Stock Items', value: '8', valueType: ReportValueType.number),
  ReportMetricDef(id: 'out-of-stock', title: 'Out of Stock', value: '2', valueType: ReportValueType.number),
  ReportMetricDef(id: 'product-views', title: 'Product Views', value: '1,245', valueType: ReportValueType.number),
  ReportMetricDef(id: 'cart-abandonment', title: 'Cart Abandonment', value: '23.5%', valueType: ReportValueType.number),
  ReportMetricDef(id: 'peak-hours', title: 'Peak Hours', value: '12-2 PM', valueType: ReportValueType.number),
  ReportMetricDef(id: 'daily-revenue', title: 'Daily Revenue', value: r'$456.78', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'weekly-growth', title: 'Weekly Growth', value: '8.2%', valueType: ReportValueType.number),
  ReportMetricDef(id: 'monthly-recurring', title: 'Monthly Recurring', value: r'$2,340.50', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'labor-cost', title: 'Labor Cost', value: r'$890.25', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'food-cost', title: 'Food Cost', value: r'$445.80', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'overhead-cost', title: 'Overhead Cost', value: r'$234.50', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'profit-margin', title: 'Profit Margin', value: '18.5%', valueType: ReportValueType.number),
  ReportMetricDef(id: 'break-even', title: 'Break Even', value: r'$1,200.00', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'promotion-usage', title: 'Promotion Usage', value: '34', valueType: ReportValueType.number),
  ReportMetricDef(id: 'loyalty-points', title: 'Loyalty Points Used', value: '1,250', valueType: ReportValueType.number),
  ReportMetricDef(id: 'referral-revenue', title: 'Referral Revenue', value: r'$178.90', valueType: ReportValueType.currency),
  ReportMetricDef(id: 'social-media-orders', title: 'Social Media Orders', value: '12', valueType: ReportValueType.number),
  ReportMetricDef(id: 'local-orders', title: 'Local Orders', value: '78', valueType: ReportValueType.number),
  ReportMetricDef(id: 'delivery-orders', title: 'Delivery Orders', value: '56', valueType: ReportValueType.number),
  ReportMetricDef(id: 'pickup-orders', title: 'Pickup Orders', value: '34', valueType: ReportValueType.number),
  ReportMetricDef(id: 'dine-in-orders', title: 'Dine-in Orders', value: '67', valueType: ReportValueType.number),
  ReportMetricDef(id: 'delivery-time', title: 'Avg Delivery Time', value: '28 min', valueType: ReportValueType.number),
  ReportMetricDef(id: 'customer-satisfaction', title: 'Customer Satisfaction', value: '4.6/5', valueType: ReportValueType.number),
  ReportMetricDef(id: 'order-accuracy', title: 'Order Accuracy', value: '96.8%', valueType: ReportValueType.number),
  ReportMetricDef(id: 'service-rating', title: 'Service Rating', value: '4.5/5', valueType: ReportValueType.number),
  ReportMetricDef(id: 'complaint-rate', title: 'Complaint Rate', value: '1.2%', valueType: ReportValueType.number),
];

ReportMetricDef? reportMetricById(String id) {
  for (final m in kReportAvailableMetrics) {
    if (m.id == id) return m;
  }
  return null;
}

/// React `window.location.href` branches mapped to app routes (placeholders).
String reportViewMoreRoute(String metricId) {
  const sales = {
    'gross-sales',
    'net-sales',
    'total-orders',
    'total-transactions',
    'average-order-value',
    'total-refunds',
    'total-discounts',
    'total-tax',
    'total-tips',
    'total-delivery-fees',
  };
  const customers = {
    'customer-count',
    'new-customers',
    'returning-customers',
    'customer-lifetime-value',
    'conversion-rate',
    'return-rate',
  };
  const operations = {'labor-cost', 'food-cost', 'overhead-cost', 'profit-margin', 'break-even'};
  const products = {'top-products', 'low-stock-items', 'out-of-stock', 'product-views', 'cart-abandonment', 'items-sold'};
  const payments = {'cash-payments', 'card-payments', 'digital-payments', 'failed-payments', 'disputed-payments'};
  const service = {
    'customer-satisfaction',
    'order-accuracy',
    'service-rating',
    'complaint-rate',
    'delivery-time',
    'peak-hours',
  };
  if (sales.contains(metricId)) return '/sales';
  if (customers.contains(metricId)) return '/guests';
  if (operations.contains(metricId)) return '/workforce';
  if (products.contains(metricId)) return '/menu';
  if (payments.contains(metricId)) return '/sales-transaction';
  if (service.contains(metricId)) return '/analytics';
  return '/analytics';
}
