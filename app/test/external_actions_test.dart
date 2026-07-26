import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/external/external_actions.dart';
import 'package:atmfinder/favorites/favorites.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const site = AtmSite(
    id: 'site-004-1',
    institutionCode: '004',
    institutionName: '臺灣銀行',
    placeName: '館前分行',
    placeCategory: PlaceCategory.bank,
    displayAddress: '臺北市中正區館前路 49 號',
    position: GeoPoint(latitude: 25.045, longitude: 121.515),
  );

  test('導航 payload 使用 ATM 名稱、地址與座標，不包含使用者位置', () {
    final payload = const AtmExternalPayloadBuilder(
      supportEmail: 'support@example.com',
      appVersion: '1.0.0',
    ).navigation(site);

    expect(payload.scheme, 'geo');
    expect(payload.path, '25.045,121.515');
    expect(payload.queryParameters['q'], contains('館前分行'));
    expect(payload.queryParameters['q'], contains('臺北市中正區館前路 49 號'));
    expect(payload.toString(), isNot(contains('currentLocation')));
  });

  test('分享可公開開啟，ATM 回報只含穩定資料與版本', () {
    const builder = AtmExternalPayloadBuilder(
      supportEmail: 'support@example.com',
      appVersion: '1.2.3',
    );

    final share = builder.share(site);
    expect(share.publicUrl.host, 'www.google.com');
    expect(share.publicUrl.queryParameters['query'], '25.045,121.515');
    expect(share.text, contains('館前分行'));
    expect(share.text, isNot(contains('使用者位置')));

    final report = builder.reportAtm(site, datasetVersion: '2026.07.26');
    expect(report.scheme, 'mailto');
    expect(report.path, 'support@example.com');
    expect(report.queryParameters['body'], contains('site-004-1'));
    expect(report.queryParameters['body'], contains('2026.07.26'));
    expect(report.queryParameters['body'], contains('1.2.3'));
    expect(report.queryParameters['body'], isNot(contains('最近搜尋')));
  });

  test('平台無法處理導航或郵件時回傳可恢復結果並複製客服信箱', () async {
    final gateway = _FakeExternalActionGateway();
    final controller = ExternalActionsController(
      gateway: gateway,
      payloads: const AtmExternalPayloadBuilder(
        supportEmail: 'support@example.com',
        appVersion: '1.2.3',
      ),
    );

    expect(await controller.navigate(site), ExternalActionOutcome.unavailable);
    expect(
      await controller.reportAtm(site, datasetVersion: '2026.07.26'),
      ExternalActionOutcome.copiedFallback,
    );
    expect(gateway.copiedText, 'support@example.com');
  });

  testWidgets('詳情頁只透過 fake 平台邊界送出導航、分享與回報 payload', (tester) async {
    final database = AtmDatabase(NativeDatabase.memory());
    final gateway = _FakeExternalActionGateway(canOpen: true, canShare: true);
    final favorites = DriftFavoritesRepository(
      database,
      const _SingleSiteLookup(site),
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          externalActionGatewayProvider.overrideWithValue(gateway),
          externalPayloadBuilderProvider.overrideWithValue(
            const AtmExternalPayloadBuilder(
              supportEmail: 'support@example.com',
              appVersion: '1.2.3',
            ),
          ),
          favoritesRepositoryProvider.overrideWithValue(favorites),
          catalogSnapshotProvider.overrideWith(
            (ref) async => CatalogSnapshot(
              datasetVersion: '2026.07.26',
              installedAt: DateTime.utc(2026, 7, 26),
              lastRefreshedAt: DateTime.utc(2026, 7, 26),
            ),
          ),
          catalogIsStaleProvider.overrideWith((ref) async => false),
        ],
        child: const MaterialApp(
          locale: Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AtmDetailPage(site: site, showFavoriteAction: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigate = find.byKey(const ValueKey('navigate-site-004-1'));
    await tester.ensureVisible(navigate);
    await tester.tap(navigate);
    await tester.pump();
    expect(gateway.openedUris.single.scheme, 'geo');
    expect(
      gateway.openedUris.single.queryParameters['q'],
      contains(site.placeName),
    );

    final share = find.byKey(const ValueKey('share-site-004-1'));
    await tester.tap(share);
    await tester.pump();
    expect(gateway.sharedPayloads.single.publicUrl.host, 'www.google.com');

    final report = find.byKey(const ValueKey('report-site-004-1'));
    await tester.tap(report);
    await tester.pump();
    expect(gateway.openedUris.last.scheme, 'mailto');
    expect(
      gateway.openedUris.last.queryParameters['body'],
      allOf(contains(site.id), contains('2026.07.26')),
    );
  });
}

class _FakeExternalActionGateway implements ExternalActionGateway {
  _FakeExternalActionGateway({this.canOpen = false, this.canShare = false});

  final bool canOpen;
  final bool canShare;
  final List<Uri> openedUris = [];
  final List<SharePayload> sharedPayloads = [];
  String? copiedText;

  @override
  Future<void> copyText(String value) async {
    copiedText = value;
  }

  @override
  Future<bool> openUri(Uri uri) async {
    openedUris.add(uri);
    return canOpen;
  }

  @override
  Future<bool> share(SharePayload payload) async {
    sharedPayloads.add(payload);
    return canShare;
  }
}

class _SingleSiteLookup implements AtmSiteLookup {
  const _SingleSiteLookup(this.site);

  final AtmSite site;

  @override
  Future<AtmSite?> findById(String id, {bool includeRetired = false}) async {
    return id == site.id ? site : null;
  }
}
