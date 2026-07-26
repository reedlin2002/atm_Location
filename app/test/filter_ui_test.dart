import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/settings/filter_page.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('使用者選取存款篩選後會立即保存並可清除', (tester) async {
    final database = AtmDatabase(NativeDatabase.memory());
    final repository = DriftUserSettingsRepository(database);
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          locale: Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FilterPage(institutions: {'004': '臺灣銀行'}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('存款功能'));
    await tester.pumpAndSettle();
    expect((await repository.load()).filters.requiredCapabilities, {
      AtmCapability.deposit,
    });

    await tester.scrollUntilVisible(
      find.text('清除篩選'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('清除篩選'));
    await tester.pumpAndSettle();
    expect((await repository.load()).filters.isEmpty, isTrue);
  });

  testWidgets('使用者可保存多間常用銀行並指定一間主要銀行', (tester) async {
    final database = AtmDatabase(NativeDatabase.memory());
    final repository = DriftUserSettingsRepository(database);
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          locale: Locale('zh', 'TW'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FilterPage(institutions: {'004': '臺灣銀行', '812': '台新銀行'}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('preferred-bank-004')),
    );
    await tester.tap(find.byKey(const ValueKey('preferred-bank-004')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('preferred-bank-812')),
    );
    await tester.tap(find.byKey(const ValueKey('preferred-bank-812')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('primary-bank-004')));
    await tester.tap(find.byKey(const ValueKey('primary-bank-004')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('同銀行優先'));
    await tester.tap(find.text('同銀行優先'));
    await tester.pumpAndSettle();

    final saved = await repository.load();
    expect(saved.bankPreferences.preferredInstitutionCodes, {'004', '812'});
    expect(saved.bankPreferences.primaryInstitutionCode, '004');
    expect(saved.bankPreferences.preferSameBank, isTrue);
  });
}
