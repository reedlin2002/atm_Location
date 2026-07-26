import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/settings/user_settings.dart';

class LocalSettingsManager {
  const LocalSettingsManager(this._database, this._settings);

  final AtmDatabase _database;
  final UserSettingsRepository _settings;

  Future<UserSettings> clearFilters() async {
    final current = await _settings.load();
    final banks = current.bankPreferences;
    final updated = current.copyWith(
      filters: const AtmFilters(),
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: banks.preferredInstitutionCodes,
        primaryInstitutionCode: banks.primaryInstitutionCode,
      ),
    );
    await _settings.save(updated);
    return updated;
  }

  Future<void> resetAll() {
    return _database.transaction(() async {
      await _database.delete(_database.favoriteSites).go();
      await _database.delete(_database.recentPlaces).go();
      await _database.delete(_database.appPreferences).go();
      await _database.delete(_database.catalogBackupEntries).go();
      await _database.delete(_database.catalogMetadataEntries).go();
      await _database.delete(_database.atmSites).go();
    });
  }
}
