import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AtmDatabase database;

  setUp(() {
    database = AtmDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('篩選與常用銀行在 repository 重建後仍可恢復', () async {
    final repository = DriftUserSettingsRepository(database);
    await repository.save(
      const UserSettings(
        filters: AtmFilters(
          institutionCodes: {'004'},
          placeCategories: {PlaceCategory.bank},
          requiredCapabilities: {AtmCapability.deposit},
        ),
        bankPreferences: BankPreferences(
          preferredInstitutionCodes: {'004', '812'},
          primaryInstitutionCode: '004',
          preferSameBank: true,
        ),
      ),
    );

    final restored = await DriftUserSettingsRepository(database).load();

    expect(restored.filters.institutionCodes, {'004'});
    expect(restored.filters.placeCategories, {PlaceCategory.bank});
    expect(restored.filters.requiredCapabilities, {AtmCapability.deposit});
    expect(restored.bankPreferences.preferredInstitutionCodes, {'004', '812'});
    expect(restored.bankPreferences.primaryInstitutionCode, '004');
    expect(restored.bankPreferences.preferSameBank, isTrue);
  });

  test('設定主要銀行會自動加入常用銀行，移除時一併清除主要銀行', () {
    final withPrimary = const UserSettings().setPrimaryBank('004');
    expect(withPrimary.bankPreferences.preferredInstitutionCodes, {'004'});
    expect(withPrimary.bankPreferences.primaryInstitutionCode, '004');

    final removed = withPrimary.removePreferredBank('004');
    expect(removed.bankPreferences.preferredInstitutionCodes, isEmpty);
    expect(removed.bankPreferences.primaryInstitutionCode, isNull);
  });
}
