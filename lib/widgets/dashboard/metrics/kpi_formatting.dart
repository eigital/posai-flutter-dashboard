import 'package:intl/intl.dart';

/// Parity with [eatos-live-dashboard/src/lib/restaurant-kpi-data.ts].

String formatCurrency(double amount) {
  return NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2).format(amount);
}

String formatPercentage(double value, [int decimals = 1]) {
  return '${value.toStringAsFixed(decimals)}%';
}

double calculatePercentageChange(double current, double previous) {
  if (previous == 0) return 0;
  return ((current - previous) / previous) * 100;
}

typedef BenchmarkBand = ({double min, double max, double ideal});

enum BenchmarkStatus { excellent, good, warning, poor }

BenchmarkStatus getBenchmarkStatus(double value, BenchmarkBand benchmark) {
  if ((value - benchmark.ideal).abs() <= 1) return BenchmarkStatus.excellent;
  if (value >= benchmark.min && value <= benchmark.max) return BenchmarkStatus.good;
  if (value < benchmark.min - 2 || value > benchmark.max + 2) return BenchmarkStatus.poor;
  return BenchmarkStatus.warning;
}
