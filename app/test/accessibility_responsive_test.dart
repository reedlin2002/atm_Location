import 'package:atmfinder/app.dart';
import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/external/external_actions.dart';
import 'package:atmfinder/favorites/favorites.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/map/nearby_map_page.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const site = AtmSite(
    id: 'a11y-site',
    institutionCode: '004',
    institutionName: '臺灣銀行',
    placeName: '台北車站無障礙 ATM',
    placeCategory: PlaceCategory.bank,
    displayAddress: '臺北市中正區北平西路 3 號',
    position: GeoPoint(latitude: 25.0478, longitude: 121.517),
  );

  testWidgets('App 跟隨系統深色主題', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      const ProviderScope(
        child: AtmFinderApp(home: Scaffold(body: Text('theme-probe'))),
      ),
    );

    expect(
      Theme.of(tester.element(find.text('theme-probe'))).brightness,
      Brightness.dark,
    );
  });

  for (final size in <Size>[
    const Size(320, 640),
    const Size(390, 844),
    const Size(1024, 1366),
    const Size(844, 390),
  ]) {
    testWidgets('200% 字級下詳情與導航可觸達：${size.width}x${size.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final database = AtmDatabase(NativeDatabase.memory());
      final gateway = _FakeExternalActionGateway();
      final favorites = DriftFavoritesRepository(
        database,
        const _SingleSiteLookup(site),
      );
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoritesRepositoryProvider.overrideWithValue(favorites),
            userSettingsRepositoryProvider.overrideWithValue(
              const _FixedUserSettingsRepository(UserSettings()),
            ),
            catalogSnapshotProvider.overrideWith((ref) async => null),
            catalogIsStaleProvider.overrideWith((ref) async => false),
            externalActionGatewayProvider.overrideWithValue(gateway),
          ],
          child: AtmFinderApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: const TextScaler.linear(2),
              ),
              child: const AtmDetailPage(site: site),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigate = find.byKey(const ValueKey('navigate-a11y-site'));
      await tester.scrollUntilVisible(
        navigate,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.getSemantics(navigate).label, contains('導航至 ATM'));
      await tester.tap(navigate);
      await tester.pump();
      expect(gateway.opened.single.scheme, 'geo');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ATM 清單列提供不依賴地圖的完整語意與獨立收藏動作', (tester) async {
    var selected = false;
    var favorited = false;
    await tester.pumpWidget(
      ProviderScope(
        child: AtmFinderApp(
          home: Scaffold(
            body: AtmResultTile(
              site: site,
              distanceMeters: 320,
              selected: false,
              favorite: false,
              accessStatus: AtmAccessStatus.unknown,
              bankRelationship: BankRelationship.sameBank,
              onSelected: () => selected = true,
              onFavorite: () => favorited = true,
            ),
          ),
        ),
      ),
    );

    final result = find.byKey(const ValueKey('atm-site-a11y-site'));
    final semantics = tester.getSemantics(result);
    expect(
      semantics.label,
      allOf(
        contains('臺灣銀行'),
        contains('320 公尺'),
        contains('進入狀態未知'),
        contains('本行 ATM'),
      ),
    );
    expect(find.text('進入狀態：未知（無可靠時段資料）'), findsOneWidget);
    expect(find.text('本行 ATM'), findsOneWidget);
    await tester.tap(result);
    expect(selected, isTrue);
    await tester.tap(find.byKey(const ValueKey('list-favorite-a11y-site')));
    expect(favorited, isTrue);
  });

  testWidgets('ATM 詳情以 canonical institution code 顯示本行 context 與費用聲明', (
    tester,
  ) async {
    final database = AtmDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(
            DriftFavoritesRepository(database, const _SingleSiteLookup(site)),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            const _FixedUserSettingsRepository(
              UserSettings(
                bankPreferences: BankPreferences(
                  preferredInstitutionCodes: {'004'},
                  primaryInstitutionCode: '004',
                ),
              ),
            ),
          ),
          catalogSnapshotProvider.overrideWith((ref) async => null),
          catalogIsStaleProvider.overrideWith((ref) async => false),
        ],
        child: const AtmFinderApp(
          home: AtmDetailPage(
            site: site,
            bankPreferences: BankPreferences(
              preferredInstitutionCodes: {'004'},
              primaryInstitutionCode: '004',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本行 ATM'), findsOneWidget);
    expect(find.text('是否同銀行僅供辨識；實際手續費與優惠請向銀行確認。'), findsOneWidget);
    expect(find.text('進入狀態：未知（無可靠時段資料）'), findsOneWidget);
  });
}

class _SingleSiteLookup implements AtmSiteLookup {
  const _SingleSiteLookup(this.site);

  final AtmSite site;

  @override
  Future<AtmSite?> findById(String id, {bool includeRetired = false}) async {
    return id == site.id ? site : null;
  }
}

class _FakeExternalActionGateway implements ExternalActionGateway {
  final List<Uri> opened = [];

  @override
  Future<void> copyText(String value) async {}

  @override
  Future<bool> openUri(Uri uri) async {
    opened.add(uri);
    return true;
  }

  @override
  Future<bool> share(SharePayload payload) async => true;
}

class _FixedUserSettingsRepository implements UserSettingsRepository {
  const _FixedUserSettingsRepository(this.settings);

  final UserSettings settings;

  @override
  Future<UserSettings> load() async => settings;

  @override
  Future<void> save(UserSettings settings) async {}
}
