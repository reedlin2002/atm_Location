import 'dart:async';

import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/design/brand_mark.dart';
import 'package:atmfinder/external/external_actions.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/onboarding/onboarding_page.dart';
import 'package:atmfinder/settings/data_sources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('資料來源頁列出五份資料集的顯名聲明、授權條款與非官方聲明', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gateway = _RecordingGateway();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          externalActionGatewayProvider.overrideWithValue(gateway),
          catalogSnapshotProvider.overrideWith(
            (ref) async => CatalogSnapshot(
              datasetVersion: '2026.11.22.1',
              installedAt: DateTime.utc(2026, 11, 22),
              lastRefreshedAt: DateTime.utc(2026, 11, 22),
            ),
          ),
        ],
        child: _localized(const DataSourcesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(openDataAttributions, hasLength(5));
    for (final attribution in openDataAttributions) {
      expect(find.text(attribution.dataset), findsOneWidget);
      expect(
        find.text('${attribution.agency}・${attribution.year}'),
        findsWidgets,
      );
    }
    expect(
      find.textContaining('此開放資料依政府資料開放授權條款 (Open Government Data License)'),
      findsOneWidget,
    );
    expect(find.text('政府資料開放授權條款：https://data.gov.tw/license'), findsOneWidget);
    expect(find.textContaining('本 App 非任何銀行、金融機構或政府機關之官方 App'), findsOneWidget);
    expect(find.text('資料版本 2026.11.22.1'), findsOneWidget);
    expect(find.byType(BrandMark), findsOneWidget);

    await tester.tap(find.text('金融機構ATM位置查詢一覽表'));
    await tester.tap(find.byKey(const ValueKey('open-data-license')));
    await tester.pump();

    expect(gateway.opened, [
      Uri.parse('https://data.gov.tw/dataset/24333'),
      Uri.parse('https://data.gov.tw/license'),
    ]);
  });

  testWidgets('連結無法開啟時提示使用者，不會當機', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          externalActionGatewayProvider.overrideWithValue(
            _RecordingGateway(canOpen: false),
          ),
          catalogSnapshotProvider.overrideWith((ref) async => null),
        ],
        child: _localized(const DataSourcesPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-data-license')));
    await tester.pumpAndSettle();

    expect(find.text('目前沒有可處理此操作的 App，請稍後再試'), findsOneWidget);
  });

  testWidgets('啟動載入時顯示品牌畫面，而不是只有轉圈圈', (tester) async {
    final pending = Completer<AppStartupResult>();
    addTearDown(() => pending.complete(const AppStartupCatalogFailure()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStartupProvider.overrideWith((ref) => pending.future)],
        child: _localized(const AppStartupPage()),
      ),
    );
    await tester.pump();

    expect(find.byType(BrandedLoadingPage), findsOneWidget);
    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.text('台灣 ATM Finder'), findsOneWidget);
    expect(find.text('離線查詢全台 ATM'), findsOneWidget);
    expect(find.text('正在載入 ATM 資料…'), findsOneWidget);
    expect(find.text('資料來源：政府資料開放平臺'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('品牌圖示預設為裝飾，不讓 TalkBack 重複念出', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: BrandMark(size: 40)),
      ),
    );
    expect(tester.getSize(find.byType(BrandMark)), const Size(40, 40));
    expect(find.bySemanticsLabel(RegExp('.')), findsNothing);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: BrandMark(size: 40, semanticLabel: 'ATM Finder 圖示'),
        ),
      ),
    );
    expect(find.bySemanticsLabel('ATM Finder 圖示'), findsOneWidget);
    semantics.dispose();
  });
}

Widget _localized(Widget home) {
  return MaterialApp(
    locale: const Locale('zh', 'TW'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

class _RecordingGateway implements ExternalActionGateway {
  _RecordingGateway({this.canOpen = true});

  final bool canOpen;
  final List<Uri> opened = [];

  @override
  Future<void> copyText(String value) async {}

  @override
  Future<bool> openUri(Uri uri) async {
    opened.add(uri);
    return canOpen;
  }

  @override
  Future<bool> share(SharePayload payload) async => true;
}
