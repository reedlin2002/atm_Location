import 'dart:convert';

import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/catalog/atm_database.dart';
import 'package:atmfinder/search/atm_result_policy.dart';

class UserSettings {
  const UserSettings({
    this.filters = const AtmFilters(),
    this.bankPreferences = const BankPreferences(),
  });

  final AtmFilters filters;
  final BankPreferences bankPreferences;

  UserSettings copyWith({
    AtmFilters? filters,
    BankPreferences? bankPreferences,
  }) {
    return UserSettings(
      filters: filters ?? this.filters,
      bankPreferences: bankPreferences ?? this.bankPreferences,
    );
  }

  UserSettings setPrimaryBank(String institutionCode) {
    final code = institutionCode.trim();
    if (code.isEmpty) {
      throw ArgumentError.value(institutionCode, 'institutionCode');
    }
    return copyWith(
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: {
          ...bankPreferences.preferredInstitutionCodes,
          code,
        },
        primaryInstitutionCode: code,
        preferSameBank: bankPreferences.preferSameBank,
      ),
    );
  }

  UserSettings addPreferredBank(String institutionCode) {
    final code = institutionCode.trim();
    if (code.isEmpty) {
      throw ArgumentError.value(institutionCode, 'institutionCode');
    }
    return copyWith(
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: {
          ...bankPreferences.preferredInstitutionCodes,
          code,
        },
        primaryInstitutionCode: bankPreferences.primaryInstitutionCode,
        preferSameBank: bankPreferences.preferSameBank,
      ),
    );
  }

  UserSettings withSameBankPreference(bool enabled) {
    return copyWith(
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: bankPreferences.preferredInstitutionCodes,
        primaryInstitutionCode: bankPreferences.primaryInstitutionCode,
        preferSameBank: enabled,
      ),
    );
  }

  UserSettings removePreferredBank(String institutionCode) {
    final remaining = {...bankPreferences.preferredInstitutionCodes}
      ..remove(institutionCode);
    return copyWith(
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: remaining,
        primaryInstitutionCode:
            bankPreferences.primaryInstitutionCode == institutionCode
            ? null
            : bankPreferences.primaryInstitutionCode,
        preferSameBank: bankPreferences.preferSameBank,
      ),
    );
  }
}

abstract interface class UserSettingsRepository {
  Future<UserSettings> load();

  Future<void> save(UserSettings settings);
}

class DriftUserSettingsRepository implements UserSettingsRepository {
  const DriftUserSettingsRepository(this._database);

  static const _settingsKey = 'user.settings.v1';

  final AtmDatabase _database;

  @override
  Future<UserSettings> load() async {
    final row =
        await (_database.select(_database.appPreferences)
              ..where((preference) => preference.key.equals(_settingsKey)))
            .getSingleOrNull();
    if (row == null) {
      return const UserSettings();
    }
    try {
      return _decode(jsonDecode(row.value) as Map<String, Object?>);
    } on Object {
      return const UserSettings();
    }
  }

  @override
  Future<void> save(UserSettings settings) {
    return _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            key: _settingsKey,
            value: jsonEncode(_encode(settings)),
          ),
        );
  }

  static Map<String, Object?> _encode(UserSettings settings) {
    return {
      'filters': {
        'institutionCodes': settings.filters.institutionCodes.toList()..sort(),
        'placeCategories':
            settings.filters.placeCategories.map((value) => value.name).toList()
              ..sort(),
        'requiredCapabilities':
            settings.filters.requiredCapabilities
                .map((value) => value.name)
                .toList()
              ..sort(),
        'openNowOnly': settings.filters.openNowOnly,
        'twentyFourHoursOnly': settings.filters.twentyFourHoursOnly,
      },
      'banks': {
        'preferredInstitutionCodes':
            settings.bankPreferences.preferredInstitutionCodes.toList()..sort(),
        'primaryInstitutionCode':
            settings.bankPreferences.primaryInstitutionCode,
        'preferSameBank': settings.bankPreferences.preferSameBank,
      },
    };
  }

  static UserSettings _decode(Map<String, Object?> document) {
    final filters = (document['filters'] as Map<Object?, Object?>?) ?? const {};
    final banks = (document['banks'] as Map<Object?, Object?>?) ?? const {};
    return UserSettings(
      filters: AtmFilters(
        institutionCodes: _strings(filters['institutionCodes']),
        placeCategories: _enumSet(
          filters['placeCategories'],
          PlaceCategory.values,
        ),
        requiredCapabilities: _enumSet(
          filters['requiredCapabilities'],
          AtmCapability.values,
        ),
        openNowOnly: filters['openNowOnly'] == true,
        twentyFourHoursOnly: filters['twentyFourHoursOnly'] == true,
      ),
      bankPreferences: BankPreferences(
        preferredInstitutionCodes: _strings(banks['preferredInstitutionCodes']),
        primaryInstitutionCode: banks['primaryInstitutionCode'] as String?,
        preferSameBank: banks['preferSameBank'] == true,
      ),
    );
  }

  static Set<String> _strings(Object? raw) {
    return {
      for (final value in (raw as List<Object?>?) ?? const [])
        if (value is String && value.trim().isNotEmpty) value,
    };
  }

  static Set<T> _enumSet<T extends Enum>(Object? raw, List<T> values) {
    final names = _strings(raw);
    return {
      for (final value in values)
        if (names.contains(value.name)) value,
    };
  }
}
