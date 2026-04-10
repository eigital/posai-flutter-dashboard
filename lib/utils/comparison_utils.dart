// Port of [eatos-live-dashboard/src/lib/comparison-utils.ts] for dashboard widgets.

import 'dart:math';

/// Inclusive calendar date range (date-only semantics).
class CuDateRange {
  const CuDateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;
}

class CuComparisonData {
  const CuComparisonData({
    required this.currentValue,
    required this.previousValue,
    required this.currentPeriodLabel,
    required this.previousPeriodLabel,
    required this.currentRange,
    required this.previousRange,
    required this.absolute,
    required this.percentage,
    required this.isPositive,
  });

  final double currentValue;
  final double previousValue;
  final String currentPeriodLabel;
  final String previousPeriodLabel;
  final CuDateRange currentRange;
  final CuDateRange previousRange;
  final double absolute;
  final double percentage;
  final bool isPositive;
}

DateTime _d(DateTime x) => DateTime(x.year, x.month, x.day);

DateTime _addDays(DateTime d, int days) => _d(d).add(Duration(days: days));

DateTime _subDays(DateTime d, int days) => _addDays(d, -days);

DateTime _subWeeks(DateTime d, int weeks) => _subDays(d, 7 * weeks);

DateTime _subMonths(DateTime d, int months) {
  var y = d.year;
  var m = d.month - months;
  while (m < 1) {
    m += 12;
    y--;
  }
  final lastDay = DateTime(y, m + 1, 0).day;
  final day = d.day > lastDay ? lastDay : d.day;
  return DateTime(y, m, day);
}

DateTime _subYears(DateTime d, int years) {
  final y = d.year - years;
  final lastDay = DateTime(y, d.month + 1, 0).day;
  final day = d.day > lastDay ? lastDay : d.day;
  return DateTime(y, d.month, day);
}

DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime _endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

DateTime _startOfYear(DateTime d) => DateTime(d.year, 1, 1);

DateTime _endOfYear(DateTime d) => DateTime(d.year, 12, 31);

/// Mirrors [getDateRangeForPeriod] from comparison-utils.ts.
CuDateRange getDateRangeForPeriod(String period, [DateTime? baseDate]) {
  final base = _d(baseDate ?? DateTime.now());
  switch (period) {
    case 'today':
      return CuDateRange(from: base, to: base);
    case 'yesterday':
      final y = _subDays(base, 1);
      return CuDateRange(from: y, to: y);
    case 'last-7-days':
      return CuDateRange(from: _subDays(base, 6), to: base);
    case 'last-4-weeks':
      return CuDateRange(from: _subWeeks(base, 4), to: base);
    case 'this-month':
      return CuDateRange(from: _startOfMonth(base), to: _endOfMonth(base));
    case 'last-month':
      final lm = _subMonths(base, 1);
      return CuDateRange(from: _startOfMonth(lm), to: _endOfMonth(lm));
    case 'this-year':
      return CuDateRange(from: _startOfYear(base), to: _endOfYear(base));
    case 'last-year':
      final ly = _subYears(base, 1);
      return CuDateRange(from: _startOfYear(ly), to: _endOfYear(ly));
    default:
      return CuDateRange(from: base, to: base);
  }
}

/// Mirrors [getComparisonDateRange] from comparison-utils.ts.
CuDateRange getComparisonDateRange(String comparisonPeriod, CuDateRange primaryRange) {
  final from = primaryRange.from;
  final to = primaryRange.to;
  switch (comparisonPeriod) {
    case 'same-day-last-week':
      return CuDateRange(from: _subDays(from, 7), to: _subDays(to, 7));
    case 'same-day-last-month':
      return CuDateRange(from: _subMonths(from, 1), to: _subMonths(to, 1));
    case 'same-day-last-year':
      return CuDateRange(from: _subYears(from, 1), to: _subYears(to, 1));
    case 'previous-week':
      final ms = to.difference(from).inMilliseconds;
      final weekDiff = (ms / (1000 * 60 * 60 * 24 * 7)).ceil();
      return CuDateRange(
        from: _subWeeks(from, weekDiff),
        to: _subDays(from, 1),
      );
    case 'previous-month':
      return CuDateRange(from: _subMonths(from, 1), to: _subMonths(to, 1));
    case 'previous-year':
      return CuDateRange(from: _subYears(from, 1), to: _subYears(to, 1));
    default:
      final daysDiff = (to.difference(from).inMilliseconds / (1000 * 60 * 60 * 24)).ceil();
      return CuDateRange(
        from: _subDays(from, daysDiff + 1),
        to: _subDays(from, 1),
      );
  }
}

String _ordinalDay(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String _monthShort(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return m[d.month - 1];
}

/// Mirrors [formatDateRange] (date-fns `MMM do` / `MMM do yyyy`).
String formatDateRange(CuDateRange range) {
  final a = _d(range.from);
  final b = _d(range.to);
  if (a.year == b.year && a.month == b.month && a.day == b.day) {
    return '${_monthShort(a)} ${_ordinalDay(a.day)}, ${a.year}';
  }
  return '${_monthShort(a)} ${_ordinalDay(a.day)} - ${_monthShort(b)} ${_ordinalDay(b.day)}, ${b.year}';
}

double _getSeasonalFactor(DateTime date) {
  const seasonalMap = [0.8, 0.75, 0.9, 1.0, 1.1, 1.2, 1.15, 1.1, 1.05, 1.0, 1.1, 1.25];
  return seasonalMap[date.month - 1];
}

double _getBaseValueForMetric(String metricType, CuDateRange range, Random rnd) {
  final daysDiff = (range.to.difference(range.from).inMilliseconds / (1000 * 60 * 60 * 24)).ceil() + 1;
  switch (metricType) {
    case 'sales':
      return ((750 + rnd.nextDouble() * 500) * daysDiff * 100).round() / 100;
    case 'orders':
      return ((15 + rnd.nextDouble() * 25) * daysDiff).roundToDouble();
    case 'customers':
      return ((20 + rnd.nextDouble() * 40) * daysDiff).roundToDouble();
    case 'cost':
      return ((200 + rnd.nextDouble() * 300) * daysDiff * 100).round() / 100;
    default:
      return ((100 + rnd.nextDouble() * 200) * daysDiff * 100).round() / 100;
  }
}

double _generatePreviousValue(double currentValue, String metricType, CuDateRange comparisonRange, Random rnd) {
  final baseVariance = 0.85 + rnd.nextDouble() * 0.3;
  final seasonalFactor = _getSeasonalFactor(comparisonRange.from);
  return (currentValue * baseVariance * seasonalFactor * 100).round() / 100;
}

/// Mirrors [generateComparisonData] from comparison-utils.ts.
CuComparisonData generateComparisonData(
  String metricType,
  CuDateRange primaryRange,
  CuDateRange comparisonRange, {
  double? baseValue,
  Random? random,
}) {
  final rnd = random ??
      Random(Object.hash(
        metricType,
        primaryRange.from.millisecondsSinceEpoch,
        primaryRange.to.millisecondsSinceEpoch,
        comparisonRange.from.millisecondsSinceEpoch,
      ));
  final currentValue = baseValue ?? _getBaseValueForMetric(metricType, primaryRange, rnd);
  final previousValue = _generatePreviousValue(currentValue, metricType, comparisonRange, rnd);
  final absolute = currentValue - previousValue;
  final percentage = previousValue == 0 ? 0.0 : (absolute / previousValue) * 100;

  return CuComparisonData(
    currentValue: currentValue,
    previousValue: previousValue,
    currentPeriodLabel: formatDateRange(primaryRange),
    previousPeriodLabel: formatDateRange(comparisonRange),
    currentRange: primaryRange,
    previousRange: comparisonRange,
    absolute: absolute,
    percentage: percentage,
    isPositive: absolute >= 0,
  );
}

/// Smart default comparison when primary period changes — [usePersistentDateFilter] `handlePrimaryPeriodChange`.
String defaultComparisonForPrimaryBreakdown(String primary) {
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
