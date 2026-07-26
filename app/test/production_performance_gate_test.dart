import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/quality/performance_gate.dart';
import 'package:atmfinder/quality/production_performance_benchmark.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'production-like App import and query performance gate',
    _runPerformanceGate,
    timeout: const Timeout(Duration(minutes: 3)),
    tags: const ['production-performance'],
  );
}

Future<void> _runPerformanceGate() async {
  const recordCount = int.fromEnvironment(
    'PERFORMANCE_RECORDS',
    defaultValue: 25000,
  );
  const outputPath = String.fromEnvironment(
    'PERFORMANCE_OUTPUT_DIR',
    defaultValue: '../performance/reports',
  );
  const deviceProfile = String.fromEnvironment(
    'PERFORMANCE_DEVICE_PROFILE',
    defaultValue:
        'ci-host-proxy; Android 10 / 2 GB device integration rerun required',
  );

  final report = await const ProductionPerformanceBenchmark().run(
    recordCount: recordCount,
    environment: BenchmarkEnvironment(
      operatingSystem:
          '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      runtime: Platform.version,
      deviceProfile: deviceProfile,
    ),
  );
  final outputDirectory = Directory(outputPath);
  await outputDirectory.create(recursive: true);
  final stem = 'performance-${report.datasetVersion}';
  await File('${outputDirectory.path}/$stem.json').writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(report.toJson())}\n',
  );
  await File(
    '${outputDirectory.path}/$stem.md',
  ).writeAsString(report.toMarkdown());

  stdout.write(report.toMarkdown());
  expect(report.violations, isEmpty, reason: report.toMarkdown());
}
