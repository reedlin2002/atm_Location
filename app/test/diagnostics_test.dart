import 'dart:io';

import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/diagnostics/crash_diagnostics.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/settings/local_settings_manager.dart';
import 'package:atmfinder/settings/settings_page.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDirectory;
  late AtmDatabase database;
  late DriftDiagnosticsConsentRepository consent;
  late _FakeCrashDiagnosticsProvider provider;
  late CrashDiagnosticsBoundary diagnostics;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('atm-diagnostics-');
    database = AtmDatabase(
      NativeDatabase(File('${tempDirectory.path}/diagnostics.sqlite')),
    );
    consent = DriftDiagnosticsConsentRepository(database);
    provider = _FakeCrashDiagnosticsProvider();
    diagnostics = CrashDiagnosticsBoundary(
      consent: consent,
      provider: provider,
    );
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  test('預設與明確拒絕時 provider 收到零筆事件', () async {
    await diagnostics.recordNonFatal(
      StateError('query=台北車站'),
      StackTrace.current,
    );
    await diagnostics.setEnabled(false);
    await diagnostics.recordFatal(
      StateError('location=25.0,121.5'),
      StackTrace.current,
    );

    expect(await consent.isEnabled(), isFalse);
    expect(provider.initializeCount, 0);
    expect(provider.reports, isEmpty);
  });

  test('主動同意後只傳 allowlist metadata 且不傳錯誤訊息', () async {
    await diagnostics.setEnabled(true);
    await diagnostics.recordNonFatal(
      StateError('搜尋字串和精確位置不得外洩'),
      StackTrace.current,
      metadata: {
        'appVersion': '1.0.0',
        'catalogVersion': '2026.07.26',
        'operation': 'catalog-import',
        'errorCode': 'catalog-invalid',
        'latitude': 25.0478,
        'longitude': 121.517,
        'searchQuery': '台北車站',
        'recentPlaces': ['台北車站'],
        'favoriteSiteIds': ['site-1'],
        'selectedAtmId': 'site-1',
        'advertisingId': 'ad-id',
      },
    );

    expect(provider.initializeCount, 1);
    expect(provider.reports, hasLength(1));
    final report = provider.reports.single;
    expect(report.errorType, 'StateError');
    expect(report.errorType, isNot(contains('搜尋字串')));
    expect(report.metadata, {
      'appVersion': '1.0.0',
      'catalogVersion': '2026.07.26',
      'operation': 'catalog-import',
      'errorCode': 'catalog-invalid',
    });
  });

  test('同意會保存，撤回後停止事件並清除 provider 暫存', () async {
    await diagnostics.setEnabled(true);
    expect(
      await DriftDiagnosticsConsentRepository(database).isEnabled(),
      isTrue,
    );

    await diagnostics.setEnabled(false);
    await diagnostics.recordNonFatal(Exception('ignored'), StackTrace.current);

    expect(provider.clearPendingCount, 1);
    expect(provider.reports, isEmpty);
    expect(
      await DriftDiagnosticsConsentRepository(database).isEnabled(),
      isFalse,
    );
  });

  test('重設所有本機資料後同意恢復關閉', () async {
    await diagnostics.setEnabled(true);

    await LocalSettingsManager(
      database,
      DriftUserSettingsRepository(database),
    ).resetAll();

    expect(await consent.isEnabled(), isFalse);
  });

  test('provider 初始化、記錄或清除失敗都不影響呼叫端', () async {
    final failing = CrashDiagnosticsBoundary(
      consent: consent,
      provider: _FakeCrashDiagnosticsProvider(throwOnEveryCall: true),
    );

    await expectLater(failing.setEnabled(true), completes);
    await expectLater(
      failing.recordNonFatal(Exception('failure'), StackTrace.current),
      completes,
    );
    await expectLater(failing.setEnabled(false), completes);
  });

  testWidgets('設定開關明確加入與撤回同意並保存狀態', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          diagnosticsConsentRepositoryProvider.overrideWithValue(consent),
          crashDiagnosticsProvider.overrideWithValue(provider),
        ],
        child: const MaterialApp(
          locale: Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DiagnosticsConsentTile()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.byKey(const ValueKey('diagnostics-consent'));
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(await consent.isEnabled(), isTrue);
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);

    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(await consent.isEnabled(), isFalse);
    expect(provider.clearPendingCount, 1);
  });
}

class _FakeCrashDiagnosticsProvider implements CrashDiagnosticsProvider {
  _FakeCrashDiagnosticsProvider({this.throwOnEveryCall = false});

  final bool throwOnEveryCall;
  final List<CrashDiagnosticReport> reports = [];
  int initializeCount = 0;
  int clearPendingCount = 0;

  @override
  Future<void> clearPending() async {
    clearPendingCount++;
    if (throwOnEveryCall) throw StateError('clear failed');
  }

  @override
  Future<void> initialize() async {
    initializeCount++;
    if (throwOnEveryCall) throw StateError('init failed');
  }

  @override
  Future<void> record(CrashDiagnosticReport report) async {
    if (throwOnEveryCall) throw StateError('record failed');
    reports.add(report);
  }
}
