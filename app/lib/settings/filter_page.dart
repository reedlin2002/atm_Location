import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterPage extends ConsumerWidget {
  const FilterPage({required this.institutions, super.key});

  final Map<String, String> institutions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final settings = ref.watch(userSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.filtersTitle)),
      body: settings.when(
        data: (value) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              localizations.capabilitiesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final capability in AtmCapability.values)
                  FilterChip(
                    label: Text(_capabilityLabel(localizations, capability)),
                    selected: value.filters.requiredCapabilities.contains(
                      capability,
                    ),
                    onSelected: (_) =>
                        _toggleCapability(ref, value, capability),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localizations.openNow),
              value: value.filters.openNowOnly,
              onChanged: (selected) =>
                  _replaceFilters(ref, value, openNowOnly: selected),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localizations.twentyFourHours),
              value: value.filters.twentyFourHoursOnly,
              onChanged: (selected) =>
                  _replaceFilters(ref, value, twentyFourHoursOnly: selected),
            ),
            const Divider(height: 32),
            Text(
              localizations.placeCategoriesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final category in PlaceCategory.values)
                  FilterChip(
                    label: Text(_placeCategoryLabel(localizations, category)),
                    selected: value.filters.placeCategories.contains(category),
                    onSelected: (_) =>
                        _togglePlaceCategory(ref, value, category),
                  ),
              ],
            ),
            if (institutions.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                localizations.institutionFilterTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final entry in institutions.entries)
                    FilterChip(
                      label: Text(entry.value),
                      selected: value.filters.institutionCodes.contains(
                        entry.key,
                      ),
                      onSelected: (_) =>
                          _toggleInstitution(ref, value, entry.key),
                    ),
                ],
              ),
              const Divider(height: 32),
              Text(
                localizations.preferredBanksTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioGroup<String>(
                groupValue: value.bankPreferences.primaryInstitutionCode,
                onChanged: (code) {
                  if (code != null) {
                    ref
                        .read(userSettingsProvider.notifier)
                        .replace(value.setPrimaryBank(code));
                  }
                },
                child: Column(
                  children: [
                    for (final entry in institutions.entries) ...[
                      CheckboxListTile(
                        key: ValueKey('preferred-bank-${entry.key}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry.value),
                        value: value.bankPreferences.preferredInstitutionCodes
                            .contains(entry.key),
                        onChanged: (_) =>
                            _togglePreferredBank(ref, value, entry.key),
                      ),
                      if (value.bankPreferences.preferredInstitutionCodes
                          .contains(entry.key))
                        RadioListTile<String>(
                          key: ValueKey('primary-bank-${entry.key}'),
                          contentPadding: const EdgeInsets.only(left: 24),
                          title: Text(
                            '${localizations.primaryBank}：${entry.value}',
                          ),
                          value: entry.key,
                        ),
                    ],
                  ],
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localizations.preferSameBank),
                subtitle: Text(localizations.bankFeeDisclaimer),
                value: value.bankPreferences.preferSameBank,
                onChanged: (enabled) => ref
                    .read(userSettingsProvider.notifier)
                    .replace(value.withSameBankPreference(enabled)),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: value.filters.isEmpty
                  ? null
                  : () =>
                        ref.read(userSettingsProvider.notifier).clearFilters(),
              icon: const Icon(Icons.filter_alt_off),
              label: Text(localizations.clearFilters),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(localizations.loadAtmsError)),
      ),
    );
  }

  Future<void> _toggleCapability(
    WidgetRef ref,
    UserSettings current,
    AtmCapability capability,
  ) async {
    final capabilities = {...current.filters.requiredCapabilities};
    if (!capabilities.remove(capability)) {
      capabilities.add(capability);
    }
    await ref
        .read(userSettingsProvider.notifier)
        .replace(
          current.copyWith(
            filters: AtmFilters(
              institutionCodes: current.filters.institutionCodes,
              placeCategories: current.filters.placeCategories,
              requiredCapabilities: capabilities,
              openNowOnly: current.filters.openNowOnly,
              twentyFourHoursOnly: current.filters.twentyFourHoursOnly,
            ),
          ),
        );
  }

  Future<void> _togglePlaceCategory(
    WidgetRef ref,
    UserSettings current,
    PlaceCategory category,
  ) {
    final values = {...current.filters.placeCategories};
    if (!values.remove(category)) {
      values.add(category);
    }
    return _replaceFilters(ref, current, placeCategories: values);
  }

  Future<void> _toggleInstitution(
    WidgetRef ref,
    UserSettings current,
    String institutionCode,
  ) {
    final values = {...current.filters.institutionCodes};
    if (!values.remove(institutionCode)) {
      values.add(institutionCode);
    }
    return _replaceFilters(ref, current, institutionCodes: values);
  }

  Future<void> _togglePreferredBank(
    WidgetRef ref,
    UserSettings current,
    String institutionCode,
  ) {
    final updated =
        current.bankPreferences.preferredInstitutionCodes.contains(
          institutionCode,
        )
        ? current.removePreferredBank(institutionCode)
        : current.addPreferredBank(institutionCode);
    return ref.read(userSettingsProvider.notifier).replace(updated);
  }

  Future<void> _replaceFilters(
    WidgetRef ref,
    UserSettings current, {
    Set<String>? institutionCodes,
    Set<PlaceCategory>? placeCategories,
    bool? openNowOnly,
    bool? twentyFourHoursOnly,
  }) {
    return ref
        .read(userSettingsProvider.notifier)
        .replace(
          current.copyWith(
            filters: AtmFilters(
              institutionCodes:
                  institutionCodes ?? current.filters.institutionCodes,
              placeCategories:
                  placeCategories ?? current.filters.placeCategories,
              requiredCapabilities: current.filters.requiredCapabilities,
              openNowOnly: openNowOnly ?? current.filters.openNowOnly,
              twentyFourHoursOnly:
                  twentyFourHoursOnly ?? current.filters.twentyFourHoursOnly,
            ),
          ),
        );
  }

  static String _capabilityLabel(
    AppLocalizations localizations,
    AtmCapability capability,
  ) {
    return switch (capability) {
      AtmCapability.deposit => localizations.capabilityDeposit,
      AtmCapability.audioGuidance => localizations.capabilityAudioGuidance,
      AtmCapability.visualAccessibility =>
        localizations.capabilityVisualAccessibility,
      AtmCapability.wheelchairAccessibility =>
        localizations.capabilityWheelchairAccessibility,
      AtmCapability.foreignCurrencyWithdrawal =>
        localizations.capabilityForeignCurrencyWithdrawal,
    };
  }

  static String _placeCategoryLabel(
    AppLocalizations localizations,
    PlaceCategory category,
  ) {
    return switch (category) {
      PlaceCategory.bank => localizations.placeCategoryBank,
      PlaceCategory.convenienceStore =>
        localizations.placeCategoryConvenienceStore,
      PlaceCategory.postOffice => localizations.placeCategoryPostOffice,
      PlaceCategory.other => localizations.placeCategoryOther,
      PlaceCategory.unknown => localizations.placeCategoryUnknown,
    };
  }
}
