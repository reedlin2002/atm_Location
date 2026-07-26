import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ATM 詳情以使用者語言顯示座標與場所證據', (tester) async {
    final attribution = EvidenceAttribution(
      publisher: EvidencePublisher.ministryOfDigitalAffairs,
      sourceDate: DateTime.utc(2025, 11, 3),
      confidence: EvidenceConfidence.officialExact,
    );
    final site = AtmSite(
      id: 'atm-moda-evidence',
      institutionCode: '004',
      institutionName: '臺灣銀行',
      placeName: '館前分行',
      placeCategory: PlaceCategory.bank,
      county: '臺北市',
      displayAddress: '臺北市中正區館前路49號',
      position: const GeoPoint(latitude: 25.0461, longitude: 121.5141),
      coordinateEvidence: attribution,
      placeCategoryEvidence: attribution,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogSnapshotProvider.overrideWith((_) async => null),
          catalogIsStaleProvider.overrideWith((_) async => false),
        ],
        child: MaterialApp(
          locale: const Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AtmDetailPage(site: site, showFavoriteAction: false),
        ),
      ),
    );

    expect(find.text('場所類型：銀行'), findsOneWidget);
    expect(find.text('場所來源：數位發展部公開資料'), findsOneWidget);
    expect(find.text('座標來源：數位發展部公開資料'), findsOneWidget);
    expect(find.text('資料日期：2025-11-03'), findsOneWidget);
    expect(find.text('信心：官方精確匹配'), findsOneWidget);
    expect(find.textContaining('moda-cash-atm'), findsNothing);
  });
}
