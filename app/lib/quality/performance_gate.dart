import 'dart:math' as math;

abstract final class PerformanceThresholds {
  static const double minimumCoordinateCoverage = 0.98;
  static const int maximumCompressedBytes = 10 * 1024 * 1024;
  static const double maximumFirstImportP95Milliseconds = 5000;
  static const double maximumWarmStartP95Milliseconds = 2000;
  static const double maximumNearbyQueryP95Milliseconds = 300;
}

class TimingSummary {
  const TimingSummary({
    required this.sampleCount,
    required this.p50Milliseconds,
    required this.p95Milliseconds,
    required this.minimumMilliseconds,
    required this.maximumMilliseconds,
  });

  factory TimingSummary.fromSamples(List<double> samples) {
    if (samples.isEmpty ||
        samples.any((sample) => !sample.isFinite || sample < 0)) {
      throw ArgumentError.value(samples, 'samples');
    }
    final sorted = [...samples]..sort();
    return TimingSummary(
      sampleCount: sorted.length,
      p50Milliseconds: _percentile(sorted, 0.50),
      p95Milliseconds: _percentile(sorted, 0.95),
      minimumMilliseconds: sorted.first,
      maximumMilliseconds: sorted.last,
    );
  }

  final int sampleCount;
  final double p50Milliseconds;
  final double p95Milliseconds;
  final double minimumMilliseconds;
  final double maximumMilliseconds;

  Map<String, Object> toJson() => {
    'sampleCount': sampleCount,
    'p50Milliseconds': p50Milliseconds,
    'p95Milliseconds': p95Milliseconds,
    'minimumMilliseconds': minimumMilliseconds,
    'maximumMilliseconds': maximumMilliseconds,
  };

  static double _percentile(List<double> sorted, double percentile) {
    final rank = math.max(1, (percentile * sorted.length).ceil());
    return sorted[rank - 1];
  }
}

class BenchmarkEnvironment {
  const BenchmarkEnvironment({
    required this.operatingSystem,
    required this.runtime,
    required this.deviceProfile,
  });

  final String operatingSystem;
  final String runtime;
  final String deviceProfile;

  Map<String, Object> toJson() => {
    'operatingSystem': operatingSystem,
    'runtime': runtime,
    'deviceProfile': deviceProfile,
  };
}

class ProductionDataQuality {
  const ProductionDataQuality({
    required this.recordCount,
    required this.coordinateCount,
    required this.compressedBytes,
    required this.unresolvedByCounty,
  });

  final int recordCount;
  final int coordinateCount;
  final int compressedBytes;
  final Map<String, int> unresolvedByCounty;

  double get coordinateCoverage =>
      recordCount == 0 ? 0 : coordinateCount / recordCount;

  Map<String, Object> toJson() => {
    'recordCount': recordCount,
    'coordinateCount': coordinateCount,
    'coordinateCoverage': coordinateCoverage,
    'compressedBytes': compressedBytes,
    'unresolvedByCounty': unresolvedByCounty,
  };
}

class PerformanceGateReport {
  const PerformanceGateReport({
    required this.datasetVersion,
    required this.environment,
    required this.dataQuality,
    required this.timings,
  });

  final String datasetVersion;
  final BenchmarkEnvironment environment;
  final ProductionDataQuality dataQuality;
  final Map<String, TimingSummary> timings;

  Set<String> get violations {
    final result = <String>{};
    if (dataQuality.coordinateCoverage <
        PerformanceThresholds.minimumCoordinateCoverage) {
      result.add('coordinate_coverage_below_98_percent');
    }
    if (dataQuality.compressedBytes >
        PerformanceThresholds.maximumCompressedBytes) {
      result.add('compressed_snapshot_over_10_mb');
    }
    _addTimingViolation(
      result,
      metric: 'firstImport',
      maximum: PerformanceThresholds.maximumFirstImportP95Milliseconds,
      violation: 'first_import_p95_over_5000_ms',
    );
    _addTimingViolation(
      result,
      metric: 'warmStart',
      maximum: PerformanceThresholds.maximumWarmStartP95Milliseconds,
      violation: 'warm_start_p95_over_2000_ms',
    );
    _addTimingViolation(
      result,
      metric: 'nearbyQuery',
      maximum: PerformanceThresholds.maximumNearbyQueryP95Milliseconds,
      violation: 'nearby_query_p95_over_300_ms',
    );
    return Set.unmodifiable(result);
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'datasetVersion': datasetVersion,
    'environment': environment.toJson(),
    'dataQuality': dataQuality.toJson(),
    'timings': {
      for (final entry in timings.entries) entry.key: entry.value.toJson(),
    },
    'thresholds': {
      'minimumCoordinateCoverage':
          PerformanceThresholds.minimumCoordinateCoverage,
      'maximumCompressedBytes': PerformanceThresholds.maximumCompressedBytes,
      'maximumFirstImportP95Milliseconds':
          PerformanceThresholds.maximumFirstImportP95Milliseconds,
      'maximumWarmStartP95Milliseconds':
          PerformanceThresholds.maximumWarmStartP95Milliseconds,
      'maximumNearbyQueryP95Milliseconds':
          PerformanceThresholds.maximumNearbyQueryP95Milliseconds,
    },
    'status': violations.isEmpty ? 'passed' : 'failed',
    'violations': violations.toList()..sort(),
  };

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# ATM Finder performance gate')
      ..writeln()
      ..writeln('- Dataset: `$datasetVersion`')
      ..writeln('- Device profile: `${environment.deviceProfile}`')
      ..writeln('- OS: `${environment.operatingSystem}`')
      ..writeln('- Runtime: `${environment.runtime}`')
      ..writeln(
        '- Coordinate coverage: '
        '${(dataQuality.coordinateCoverage * 100).toStringAsFixed(2)}%',
      )
      ..writeln('- Compressed bytes: ${dataQuality.compressedBytes}')
      ..writeln()
      ..writeln('| Metric | Samples | p50 (ms) | p95 (ms) |')
      ..writeln('|---|---:|---:|---:|');
    for (final entry in timings.entries) {
      buffer.writeln(
        '| ${entry.key} | ${entry.value.sampleCount} | '
        '${entry.value.p50Milliseconds.toStringAsFixed(2)} | '
        '${entry.value.p95Milliseconds.toStringAsFixed(2)} |',
      );
    }
    buffer
      ..writeln()
      ..writeln(
        violations.isEmpty
            ? '**Status: PASSED**'
            : '**Status: FAILED** — ${violations.join(', ')}',
      );
    return buffer.toString();
  }

  void _addTimingViolation(
    Set<String> target, {
    required String metric,
    required double maximum,
    required String violation,
  }) {
    final timing = timings[metric];
    if (timing == null || timing.p95Milliseconds > maximum) {
      target.add(violation);
    }
  }
}
