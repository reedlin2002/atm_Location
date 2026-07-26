import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ATM 詳情區分授權精確定位與人工審核座標信心', (tester) async {
    final site = AtmSite(
      id: 'atm-licensed-geocode',
      institutionCode: '004',
      institutionName: '臺灣銀行',
      placeName: '館前分行',
      placeCategory: PlaceCategory.bank,
      displayAddress: '臺北市中正區館前路49號',
      position: const GeoPoint(latitude: 25.0461, longitude: 121.5141),
      coordinateEvidence: EvidenceAttribution(
        publisher: EvidencePublisher.licensedGeocoder,
        sourceDate: DateTime.utc(2026, 7, 25),
        confidence: EvidenceConfidence.licensedExact,
      ),
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

    expect(find.text('座標來源：已核准地址定位服務'), findsOneWidget);
    expect(find.text('信心：授權來源精確匹配'), findsOneWidget);
    expect(find.textContaining('licensed-address-geocoder'), findsNothing);
  });
}
