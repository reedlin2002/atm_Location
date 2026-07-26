import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/external/external_actions.dart';
import 'package:atmfinder/favorites/favorites_page.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/onboarding/onboarding_page.dart';
import 'package:atmfinder/search/recent_places.dart';
import 'package:atmfinder/settings/filter_page.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({this.onReset, super.key});

  final Future<void> Function()? onReset;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Future<List<RecentPlace>> _recentPlaces;

  @override
  void initState() {
    super.initState();
    _recentPlaces = ref.read(recentPlacesRepositoryProvider).list();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final settings =
        ref.watch(userSettingsProvider).value ?? const UserSettings();
    final favoriteCount = ref.watch(favoritesProvider).value?.length ?? 0;
    final knownInstitutions = {
      for (final code in settings.bankPreferences.preferredInstitutionCodes)
        code: code,
    };

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(localizations.localDataOnlyTitle),
              subtitle: Text(localizations.localDataOnlyBody),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(localizations.searchPreferences),
            subtitle: Text(localizations.manageFilters),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FilterPage(institutions: knownInstitutions),
              ),
            ),
          ),
          ListTile(
            key: const ValueKey('clear-filters'),
            leading: const Icon(Icons.filter_alt_off_outlined),
            title: Text(localizations.clearFilters),
            onTap: () async {
              await ref.read(userSettingsProvider.notifier).clearFilters();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.filtersCleared)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(localizations.favoritesTitle),
            subtitle: Text(localizations.favoriteCount(favoriteCount)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FavoritesPage()),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(localizations.recentPlaces),
            trailing: TextButton(
              key: const ValueKey('clear-recent-places'),
              onPressed: () async {
                await ref.read(recentPlacesRepositoryProvider).clear();
                _reloadRecentPlaces();
              },
              child: Text(localizations.clearAll),
            ),
          ),
          FutureBuilder<List<RecentPlace>>(
            future: _recentPlaces,
            builder: (context, snapshot) {
              final places = snapshot.data;
              if (places == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (places.isEmpty) {
                return ListTile(title: Text(localizations.noRecentPlaces));
              }
              return Column(
                children: [
                  for (final place in places)
                    ListTile(
                      title: Text(place.label),
                      trailing: IconButton(
                        key: ValueKey('delete-recent-${place.label}'),
                        tooltip: localizations.deleteRecentPlace,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref
                              .read(recentPlacesRepositoryProvider)
                              .delete(place.label);
                          _reloadRecentPlaces();
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(localizations.reviewOnboarding),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (routeContext) => OnboardingPage(
                  reviewMode: true,
                  onFinished: () async => Navigator.of(routeContext).pop(),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(localizations.settingsFeedback),
            onTap: () async {
              final outcome = await ref
                  .read(externalActionsControllerProvider)
                  .generalFeedback();
              if (!context.mounted ||
                  outcome == ExternalActionOutcome.launched) {
                return;
              }
              final message = outcome == ExternalActionOutcome.copiedFallback
                  ? localizations.supportEmailCopied
                  : localizations.externalActionUnavailable;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
          ),
          const DiagnosticsConsentTile(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const ValueKey('reset-all-local-data'),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(localizations.resetAllLocalData),
            onPressed: _confirmAndReset,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.resetAllDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _reloadRecentPlaces() {
    setState(() {
      _recentPlaces = ref.read(recentPlacesRepositoryProvider).list();
    });
  }

  Future<void> _confirmAndReset() async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.resetDialogTitle),
        content: Text(localizations.resetDialogBody),
        actions: [
          TextButton(
            key: const ValueKey('cancel-reset'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-reset'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.confirmReset),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    await ref.read(localSettingsManagerProvider).resetAll();
    ref.invalidate(userSettingsProvider);
    ref.invalidate(favoritesProvider);
    ref.invalidate(catalogSnapshotProvider);
    ref.invalidate(catalogIsStaleProvider);
    ref.invalidate(diagnosticsConsentProvider);
    ref.invalidate(appStartupProvider);
    ref.read(homeSearchProvider.notifier).reset();
    await widget.onReset?.call();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(localizations.resetComplete)));
  }
}

class DiagnosticsConsentTile extends ConsumerWidget {
  const DiagnosticsConsentTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final consent = ref.watch(diagnosticsConsentProvider);
    return SwitchListTile(
      key: const ValueKey('diagnostics-consent'),
      secondary: const Icon(Icons.bug_report_outlined),
      title: Text(localizations.diagnosticsTitle),
      subtitle: Text(localizations.diagnosticsBody),
      value: consent.value ?? false,
      onChanged: consent.isLoading
          ? null
          : (enabled) => ref
                .read(diagnosticsConsentProvider.notifier)
                .setEnabled(enabled),
    );
  }
}
