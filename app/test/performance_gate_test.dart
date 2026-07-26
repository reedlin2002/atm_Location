import 'package:atmfinder/quality/performance_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('統計報告固定產生樣本數、p50 與 p95', () {
    final summary = TimingSummary.fromSamples(
      List<double>.generate(20, (index) => (index + 1).toDouble()),
    );

    expect(summary.sampleCount, 20);
    expect(summary.p50Milliseconds, 10);
    expect(summary.p95Milliseconds, 19);
  });

  test('正式資料與效能任一硬門檻失敗都會列入 gate violations', () {
    final report = PerformanceGateReport(
      datasetVersion: 'production-like-2026.07.26',
      environment: const BenchmarkEnvironment(
        operatingSystem: 'test',
        runtime: 'test',
        deviceProfile: 'minimum-supported-proxy',
      ),
      dataQuality: const ProductionDataQuality(
        recordCount: 100,
        coordinateCount: 97,
        compressedBytes: 10 * 1024 * 1024 + 1,
        unresolvedByCounty: {'未知': 3},
      ),
      timings: {
        'firstImport': TimingSummary.fromSamples([5001]),
        'warmStart': TimingSummary.fromSamples([2001]),
        'nearbyQuery': TimingSummary.fromSamples([100, 301]),
      },
    );

    expect(report.violations, {
      'coordinate_coverage_below_98_percent',
      'compressed_snapshot_over_10_mb',
      'first_import_p95_over_5000_ms',
      'warm_start_p95_over_2000_ms',
      'nearby_query_p95_over_300_ms',
    });
    expect(report.toJson()['environment'], isA<Map<String, Object?>>());
    expect(report.toMarkdown(), contains('p95'));
  });

  test('門檻邊界值可通過且不會默默放寬', () {
    final report = PerformanceGateReport(
      datasetVersion: 'production-like-2026.07.26',
      environment: const BenchmarkEnvironment(
        operatingSystem: 'test',
        runtime: 'test',
        deviceProfile: 'minimum-supported-proxy',
      ),
      dataQuality: const ProductionDataQuality(
        recordCount: 100,
        coordinateCount: 98,
        compressedBytes: 10 * 1024 * 1024,
        unresolvedByCounty: {'臺東縣': 2},
      ),
      timings: {
        'firstImport': TimingSummary.fromSamples([5000]),
        'warmStart': TimingSummary.fromSamples([2000]),
        'nearbyQuery': TimingSummary.fromSamples([300]),
      },
    );

    expect(report.violations, isEmpty);
  });
}
