import 'package:atmfinder/catalog/atm_database.dart';

abstract interface class OnboardingPreferences {
  Future<bool> isComplete();

  Future<void> markComplete();
}

class DriftOnboardingPreferences implements OnboardingPreferences {
  const DriftOnboardingPreferences(this._database);

  static const _completionKey = 'onboarding.completed.v1';

  final AtmDatabase _database;

  @override
  Future<bool> isComplete() async {
    final preference = await (_database.select(
      _database.appPreferences,
    )..where((row) => row.key.equals(_completionKey))).getSingleOrNull();
    return preference?.value == 'true';
  }

  @override
  Future<void> markComplete() {
    return _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(key: _completionKey, value: 'true'),
        );
  }
}
