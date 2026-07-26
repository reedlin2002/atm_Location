import 'dart:convert';
import 'dart:io';

import 'package:atmfinder/quality/performance_gate.dart';
import 'package:atmfinder/quality/production_performance_benchmark.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android 10 / 2 GB production-like performance gate',
    (tester) async {
      expect(
        Platform.isAndroid,
        isTrue,
        reason: 'This gate must execute in the Android application runtime.',
      );
      const deviceProfile = String.fromEnvironment(
        'PERFORMANCE_DEVICE_PROFILE',
      );
      expect(deviceProfile, isNotEmpty);

      final report = await const ProductionPerformanceBenchmark().run(
        recordCount: 25000,
        environment: BenchmarkEnvironment(
          operatingSystem:
              '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
          runtime: Platform.version,
          deviceProfile: deviceProfile,
        ),
      );

      binding.reportData = {'performanceReport': report.toJson()};
      // A stable marker lets the host-side runner persist the device-produced
      // report without granting the App broad external-storage permissions.
      debugPrintSynchronously(
        'ATM_PERFORMANCE_REPORT_JSON=${jsonEncode(report.toJson())}',
        wrapWidth: null,
      );
      expect(report.violations, isEmpty, reason: report.toMarkdown());
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
