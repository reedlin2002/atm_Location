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

void main() {
  testWidgets('首次開啟顯示可略過引導，略過後首頁仍不要求定位', (tester) async {
    final database = AtmDatabase(NativeDatabase.memory());
    final preferences = _MemoryOnboardingPreferences();
    final location = _SpyLocationGateway();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          atmDatabaseProvider.overrideWithValue(database),
          onboardingPreferencesProvider.overrideWithValue(preferences),
          locationGatewayProvider.overrideWithValue(location),
          mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
        ],
        child: const AtmFinderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('歡迎使用台灣 ATM Finder'), findsOneWidget);
    expect(find.text('定位用途'), findsOneWidget);
    expect(find.text('資料來源'), findsOneWidget);
    expect(find.text('隱私說明'), findsOneWidget);
    expect(find.text('略過'), findsOneWidget);
    expect(location.requestCount, 0);

    await tester.tap(find.text('略過'));
    await tester.pumpAndSettle();

    expect(find.text('附近 ATM'), findsOneWidget);
    expect(find.text('找我附近'), findsOneWidget);
    expect(find.text('歡迎使用台灣 ATM Finder'), findsNothing);
    expect(location.requestCount, 0);
    expect(await preferences.isComplete(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          atmDatabaseProvider.overrideWithValue(database),
          onboardingPreferencesProvider.overrideWithValue(preferences),
          locationGatewayProvider.overrideWithValue(location),
          mapAdapterProvider.overrideWithValue(const _StubMapAdapter()),
        ],
        child: const AtmFinderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('歡迎使用台灣 ATM Finder'), findsNothing);
    expect(find.text('附近 ATM'), findsOneWidget);
    expect(location.requestCount, 0);

    await tester.tap(find.byTooltip('更多選項'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('使用說明'));
    await tester.pumpAndSettle();
    expect(find.text('歡迎使用台灣 ATM Finder'), findsOneWidget);
    expect(find.text('返回'), findsOneWidget);
    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();

    expect(find.text('附近 ATM'), findsOneWidget);
    expect(preferences.markCount, 1);
  });

  test(
    'completion flag persists locally without replacing other preferences',
    () async {
      final database = AtmDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.appPreferences)
          .insert(
            AppPreferencesCompanion.insert(
              key: 'appearance.theme',
              value: 'dark',
            ),
          );
      final preferences = DriftOnboardingPreferences(database);

      expect(await preferences.isComplete(), isFalse);
      await preferences.markComplete();

      expect(await DriftOnboardingPreferences(database).isComplete(), isTrue);
      final theme = await (database.select(
        database.appPreferences,
      )..where((row) => row.key.equals('appearance.theme'))).getSingle();
      expect(theme.value, 'dark');
      await database.close();

      final resetDatabase = AtmDatabase(NativeDatabase.memory());
      addTearDown(resetDatabase.close);
      expect(
        await DriftOnboardingPreferences(resetDatabase).isComplete(),
        isFalse,
      );
    },
  );
}

class _MemoryOnboardingPreferences implements OnboardingPreferences {
  bool completed = false;
  int markCount = 0;

  @override
  Future<bool> isComplete() async => completed;

  @override
  Future<void> markComplete() async {
    markCount += 1;
    completed = true;
  }
}

class _SpyLocationGateway implements LocationGateway {
  int requestCount = 0;

  @override
  Future<LocationOutcome> currentPosition() async {
    requestCount += 1;
    return const LocationUnavailable();
  }
}

class _StubMapAdapter implements MapAdapter {
  const _StubMapAdapter();

  @override
  Widget buildMap(MapPresentation presentation) => const SizedBox.shrink();
}
