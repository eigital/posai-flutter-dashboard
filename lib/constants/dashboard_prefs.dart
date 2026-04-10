/// SharedPreferences keys for dashboard UI (mirrors React localStorage keys).
const String kUnifiedMetricsPrefsKey = 'unified_metrics_dashboard';

/// [eatos-live-dashboard/src/hooks/use-persistent-date-filter.ts] uses
/// `${storageKey}-primary` / `${storageKey}-comparison` with storageKey `reports-overview`.
const String kReportsOverviewStorageKey = 'reports-overview';

/// [eatos-live-dashboard/src/components/reports-overview.tsx] `reports-overview-metrics`.
const String kReportsOverviewMetricsKey = 'reports-overview-metrics';

/// [usePersistentDateFilter] storageKey `breakdown-report`.
const String kBreakdownReportStorageKey = 'breakdown-report';

/// [breakdown-report.tsx] `breakdown-report-metrics`.
const String kBreakdownReportMetricsKey = 'breakdown-report-metrics';
