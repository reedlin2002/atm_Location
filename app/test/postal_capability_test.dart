import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ATM 詳情明確區分已確認能力與未知能力', (tester) async {
    final attribution = EvidenceAttribution(
      publisher: EvidencePublisher.chunghwaPost,
      sourceDate: DateTime.utc(2026, 7, 25),
      confidence: EvidenceConfidence.officialPositive,
    );
    final site = AtmSite(
      id: 'atm-postal-capabilities',
      institutionCode: '700',
      institutionName: '中華郵政',
      placeName: '臺北北門郵局',
      placeCategory: PlaceCategory.postOffice,
      county: '臺北市',
      displayAddress: '臺北市中正區忠孝西路一段120號',
      position: const GeoPoint(latitude: 25.0478, longitude: 121.5104),
      capabilities: [
        CapabilityFact(
          capability: AtmCapability.deposit,
          status: CapabilityStatus.confirmed,
          evidence: attribution,
        ),
        CapabilityFact(
          capability: AtmCapability.audioGuidance,
          status: CapabilityStatus.confirmed,
          evidence: attribution,
        ),
      ],
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

    expect(find.text('存款功能：已確認'), findsOneWidget);
    expect(find.text('語音引導：已確認'), findsOneWidget);
    expect(find.text('輪椅無障礙：未知'), findsOneWidget);
    expect(find.text('視障無障礙：未知'), findsOneWidget);
    expect(find.textContaining('chunghwa-post-atm'), findsNothing);
  });
}
