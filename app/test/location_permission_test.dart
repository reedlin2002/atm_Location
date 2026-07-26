import 'dart:io';

import 'package:atmfinder/app.dart';
import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/onboarding/onboarding_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late AtmDatabase _database;

void main() {
  setUpAll(() {
    _database = AtmDatabase(NativeDatabase.memory());
  });

  tearDownAll(() => _database.close());

  testWidgets('開啟 App 不要求定位，點找我附近後 approximate location 也可搜尋', (tester) async {
    final location = _FakeLocationGateway(
      const LocationAvailable(
        GeoPoint(latitude: 25.0478, longitude: 121.5170),
        accuracy: ForegroundLocationAccuracy.approximate,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          atmDatabaseProvider.overrideWithValue(_database),
          onboardingPreferencesProvider.overrideWithValue(
            const _CompletedOnboardingPreferences(),
          ),
          locationGatewayProvider.overrideWithValue(location),
          mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
        ],
        child: const AtmFinderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(location.requestCount, 0);
    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();

    expect(location.requestCount, 1);
    expect(find.text('臺灣銀行'), findsOneWidget);
    expect(await _database.select(_database.appPreferences).get(), isEmpty);
    expect(await _database.select(_database.recentPlaces).get(), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('denied 顯示手動搜尋替代方案', (tester) async {
    final location = await _pumpWithOutcome(
      tester,
      const LocationPermissionDenied(),
    );

    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();

    expect(find.text('未授權定位，仍可使用手動搜尋'), findsOneWidget);
    expect(find.text('手動搜尋'), findsOneWidget);
    expect(location.requestCount, 1);
    await tester.tap(find.text('手動搜尋'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('offline-search-field')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('permanently denied 提供開啟系統設定 action', (tester) async {
    final location = await _pumpWithOutcome(
      tester,
      const LocationPermissionDeniedForever(),
    );

    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('前往系統設定'));

    expect(find.text('定位權限已永久拒絕，請到系統設定開啟'), findsOneWidget);
    expect(location.openAppSettingsCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('定位關閉與 provider error 顯示不同可重試訊息', (tester) async {
    final location = await _pumpWithOutcome(
      tester,
      const LocationServicesDisabled(),
    );

    await tester.tap(find.text('找我附近'));
    await tester.pumpAndSettle();
    expect(find.text('裝置的定位服務已關閉'), findsOneWidget);
    await tester.tap(find.text('開啟定位設定'));
    expect(location.openLocationSettingsCount, 1);

    location.outcome = const LocationProviderFailure();
    await tester.tap(find.text('重新嘗試'));
    await tester.pumpAndSettle();
    expect(find.text('暫時無法取得位置，請稍後再試'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Android 只宣告前景定位且沒有背景定位或通知權限', () async {
    final manifest = await File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsString();

    expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
    expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
    expect(
      manifest,
      isNot(contains('android.permission.ACCESS_BACKGROUND_LOCATION')),
    );
    expect(manifest, isNot(contains('android.permission.POST_NOTIFICATIONS')));
  });
}

Future<_FakeLocationGateway> _pumpWithOutcome(
  WidgetTester tester,
  LocationOutcome outcome,
) async {
  final location = _FakeLocationGateway(outcome);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        atmDatabaseProvider.overrideWithValue(_database),
        onboardingPreferencesProvider.overrideWithValue(
          const _CompletedOnboardingPreferences(),
        ),
        locationGatewayProvider.overrideWithValue(location),
        mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
      ],
      child: const AtmFinderApp(),
    ),
  );
  await tester.pumpAndSettle();
  return location;
}

class _FakeLocationGateway
    implements LocationGateway, LocationSettingsLauncher {
  _FakeLocationGateway(this.outcome);

  LocationOutcome outcome;
  int requestCount = 0;
  int openAppSettingsCount = 0;
  int openLocationSettingsCount = 0;

  @override
  Future<LocationOutcome> currentPosition() async {
    requestCount += 1;
    return outcome;
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCount += 1;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    openLocationSettingsCount += 1;
    return true;
  }
}

class _CompletedOnboardingPreferences implements OnboardingPreferences {
  const _CompletedOnboardingPreferences();

  @override
  Future<bool> isComplete() async => true;

  @override
  Future<void> markComplete() async {}
}

class _StubMapAdapter implements MapAdapter {
  const _StubMapAdapter();

  @override
  Widget buildMap(MapPresentation presentation) => const SizedBox.shrink();
}
