import 'dart:math' as math;

import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/design/app_theme.dart';
import 'package:atmfinder/detail/atm_detail_page.dart';
import 'package:atmfinder/favorites/favorites_page.dart';
import 'package:atmfinder/home/home_search.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/l10n/result_context_labels.dart';
import 'package:atmfinder/map/map_adapter.dart';
import 'package:atmfinder/map/map_clustering.dart';
import 'package:atmfinder/onboarding/onboarding_page.dart';
import 'package:atmfinder/search/offline_search_page.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:atmfinder/settings/filter_page.dart';
import 'package:atmfinder/settings/settings_page.dart';
import 'package:atmfinder/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The stable ATM id currently selected. Shared by the map markers and the
/// list so a selection from either surface focuses the same ATM.
final selectedSiteProvider = NotifierProvider<SelectedSiteController, String?>(
  SelectedSiteController.new,
);

enum _AppMenuAction { favorites, help, settings }

class SelectedSiteController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String siteId) => state = siteId;

  void clear() => state = null;
}

/// Whether the map surface is usable. Flipped to false when the map SDK cannot
/// initialise so the page can degrade to the list + detail flow.
final mapAvailableProvider = NotifierProvider<MapAvailabilityController, bool>(
  MapAvailabilityController.new,
);

class MapAvailabilityController extends Notifier<bool> {
  @override
  bool build() => true;

  void markUnavailable() => state = false;
}

/// Shows nearby ATMs on a map and a list at once, sharing one selection.
class NearbyMapPage extends ConsumerWidget {
  const NearbyMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final homeState = ref.watch(homeSearchProvider);
    final isStale = ref.watch(catalogIsStaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.nearbyAtmsTitle),
        actions: [
          IconButton(
            tooltip: localizations.filtersTitle,
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {
              final institutions = <String, String>{};
              if (homeState.value case HomeSearchSuccess(:final sites)) {
                for (final result in sites) {
                  institutions[result.site.institutionCode] =
                      result.site.institutionName;
                }
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FilterPage(institutions: institutions),
                ),
              );
            },
          ),
          IconButton(
            tooltip: localizations.manualSearch,
            icon: const Icon(Icons.search),
            onPressed: () => _openOfflineSearch(context),
          ),
          PopupMenuButton<_AppMenuAction>(
            tooltip: localizations.moreOptions,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _AppMenuAction.favorites,
                child: ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: Text(localizations.favoritesTitle),
                ),
              ),
              PopupMenuItem(
                value: _AppMenuAction.help,
                child: ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(localizations.onboardingHelpTitle),
                ),
              ),
              PopupMenuItem(
                value: _AppMenuAction.settings,
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(localizations.settingsTitle),
                ),
              ),
            ],
            onSelected: (action) {
              switch (action) {
                case _AppMenuAction.favorites:
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FavoritesPage(),
                    ),
                  );
                case _AppMenuAction.help:
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (routeContext) => OnboardingPage(
                        reviewMode: true,
                        onFinished: () async =>
                            Navigator.of(routeContext).pop(),
                      ),
                    ),
                  );
                case _AppMenuAction.settings:
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isStale.value == true)
            _CatalogStaleBanner(message: localizations.staleDataWarning),
          Expanded(
            child: homeState.when(
              data: (result) => switch (result) {
                HomeSearchIdle() => Center(
                  child: FilledButton.icon(
                    onPressed: () =>
                        ref.read(homeSearchProvider.notifier).findNearby(),
                    icon: const Icon(Icons.my_location),
                    label: Text(localizations.findNearby),
                  ),
                ),
                HomeSearchSuccess(:final sites, :final radiusMeters)
                    when sites.isEmpty && radiusMeters >= 10000 =>
                  _NoNearbyRecovery(
                    onClearFilters: () =>
                        ref.read(homeSearchProvider.notifier).reset(),
                    onExpand: () => ref
                        .read(homeSearchProvider.notifier)
                        .findNearby(expanded: true),
                    onSearchMapArea: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const OfflineSearchPage(mapAreaMode: true),
                      ),
                    ),
                  ),
                HomeSearchSuccess(:final sites) when sites.isEmpty => Center(
                  child: Text(localizations.noNearbyAtms),
                ),
                HomeSearchSuccess(:final sites, :final radiusMeters) =>
                  _FilteredNearbyView(sites: sites, radiusMeters: radiusMeters),
                HomeSearchLocationDenied() => _LocationRecovery(
                  message: localizations.locationDeniedMessage,
                  primaryLabel: localizations.manualSearch,
                  onPrimary: () => _openOfflineSearch(context),
                ),
                HomeSearchLocationDeniedForever() => _LocationRecovery(
                  message: localizations.locationDeniedForeverMessage,
                  primaryLabel: localizations.openSystemSettings,
                  onPrimary: () =>
                      ref.read(homeSearchProvider.notifier).openAppSettings(),
                ),
                HomeSearchLocationServicesDisabled() => _LocationRecovery(
                  message: localizations.locationServicesDisabledMessage,
                  primaryLabel: localizations.openLocationSettings,
                  onPrimary: () => ref
                      .read(homeSearchProvider.notifier)
                      .openLocationSettings(),
                  secondaryLabel: localizations.retry,
                  onSecondary: () =>
                      ref.read(homeSearchProvider.notifier).findNearby(),
                ),
                HomeSearchLocationProviderFailure() => _LocationRecovery(
                  message: localizations.locationProviderFailureMessage,
                  primaryLabel: localizations.retry,
                  onPrimary: () =>
                      ref.read(homeSearchProvider.notifier).findNearby(),
                ),
                HomeSearchFailure() => _LoadFailure(
                  onRetry: () =>
                      ref.read(homeSearchProvider.notifier).findNearby(),
                ),
              },
              error: (error, stackTrace) => _LoadFailure(
                onRetry: () =>
                    ref.read(homeSearchProvider.notifier).findNearby(),
              ),
              loading: () => Center(
                child: Semantics(
                  label: localizations.loadingAtms,
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openOfflineSearch(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OfflineSearchPage()));
  }
}

class _FilteredNearbyView extends ConsumerWidget {
  const _FilteredNearbyView({required this.sites, required this.radiusMeters});

  final List<NearbyAtmSite> sites;
  final double radiusMeters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).value ?? const UserSettings();
    final filtered = ref
        .watch(atmResultPolicyProvider)
        .apply(
          sites,
          filters: settings.filters,
          bankPreferences: settings.bankPreferences,
        );
    return Column(
      children: [
        if (!settings.filters.isEmpty)
          _ActiveFilters(
            filters: settings.filters,
            institutions: {
              for (final result in sites)
                result.site.institutionCode: result.site.institutionName,
            },
          ),
        Expanded(
          child: filtered.isEmpty && !settings.filters.isEmpty
              ? _FilteredEmpty(
                  onClear: () =>
                      ref.read(userSettingsProvider.notifier).clearFilters(),
                )
              : _NearbyMapView(sites: filtered, radiusMeters: radiusMeters),
        ),
      ],
    );
  }
}

class _ActiveFilters extends ConsumerWidget {
  const _ActiveFilters({required this.filters, required this.institutions});

  final AtmFilters filters;
  final Map<String, String> institutions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          for (final code in filters.institutionCodes)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(institutions[code] ?? code),
                deleteButtonTooltipMessage: localizations.removeFilter,
                onDeleted: () => _replace(
                  ref,
                  institutionCodes: {...filters.institutionCodes}..remove(code),
                ),
              ),
            ),
          for (final category in filters.placeCategories)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(_categoryLabel(localizations, category)),
                deleteButtonTooltipMessage: localizations.removeFilter,
                onDeleted: () => _replace(
                  ref,
                  placeCategories: {...filters.placeCategories}
                    ..remove(category),
                ),
              ),
            ),
          for (final capability in filters.requiredCapabilities)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(_capabilityLabel(localizations, capability)),
                deleteButtonTooltipMessage: localizations.removeFilter,
                onDeleted: () => _replace(
                  ref,
                  requiredCapabilities: {...filters.requiredCapabilities}
                    ..remove(capability),
                ),
              ),
            ),
          if (filters.openNowOnly)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(localizations.openNow),
                deleteButtonTooltipMessage: localizations.removeFilter,
                onDeleted: () => _replace(ref, openNowOnly: false),
              ),
            ),
          if (filters.twentyFourHoursOnly)
            InputChip(
              label: Text(localizations.twentyFourHours),
              deleteButtonTooltipMessage: localizations.removeFilter,
              onDeleted: () => _replace(ref, twentyFourHoursOnly: false),
            ),
        ],
      ),
    );
  }

  Future<void> _replace(
    WidgetRef ref, {
    Set<String>? institutionCodes,
    Set<PlaceCategory>? placeCategories,
    Set<AtmCapability>? requiredCapabilities,
    bool? openNowOnly,
    bool? twentyFourHoursOnly,
  }) async {
    final current =
        ref.read(userSettingsProvider).value ?? const UserSettings();
    await ref
        .read(userSettingsProvider.notifier)
        .replace(
          current.copyWith(
            filters: AtmFilters(
              institutionCodes: institutionCodes ?? filters.institutionCodes,
              placeCategories: placeCategories ?? filters.placeCategories,
              requiredCapabilities:
                  requiredCapabilities ?? filters.requiredCapabilities,
              openNowOnly: openNowOnly ?? filters.openNowOnly,
              twentyFourHoursOnly:
                  twentyFourHoursOnly ?? filters.twentyFourHoursOnly,
            ),
          ),
        );
  }

  static String _categoryLabel(
    AppLocalizations localizations,
    PlaceCategory category,
  ) => switch (category) {
    PlaceCategory.bank => localizations.placeCategoryBank,
    PlaceCategory.convenienceStore =>
      localizations.placeCategoryConvenienceStore,
    PlaceCategory.postOffice => localizations.placeCategoryPostOffice,
    PlaceCategory.other => localizations.placeCategoryOther,
    PlaceCategory.unknown => localizations.placeCategoryUnknown,
  };

  static String _capabilityLabel(
    AppLocalizations localizations,
    AtmCapability capability,
  ) => switch (capability) {
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

class _FilteredEmpty extends StatelessWidget {
  const _FilteredEmpty({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.noNearbyAtms),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onClear,
            child: Text(localizations.clearFilters),
          ),
        ],
      ),
    );
  }
}

class _LocationRecovery extends StatelessWidget {
  const _LocationRecovery({
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
          ],
        ],
      ),
    );
  }
}

class _NoNearbyRecovery extends StatelessWidget {
  const _NoNearbyRecovery({
    required this.onClearFilters,
    required this.onExpand,
    required this.onSearchMapArea,
  });

  final VoidCallback onClearFilters;
  final VoidCallback onExpand;
  final VoidCallback onSearchMapArea;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.noAtmsWithinTenKm, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onExpand,
              child: Text(localizations.expandRadius),
            ),
            TextButton(
              onPressed: onClearFilters,
              child: Text(localizations.clearFilters),
            ),
            TextButton(
              onPressed: onSearchMapArea,
              child: Text(localizations.searchMapArea),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyMapView extends ConsumerStatefulWidget {
  const _NearbyMapView({required this.sites, required this.radiusMeters});

  final List<NearbyAtmSite> sites;
  final double radiusMeters;

  @override
  ConsumerState<_NearbyMapView> createState() => _NearbyMapViewState();
}

class _NearbyMapViewState extends ConsumerState<_NearbyMapView> {
  MapCameraPosition? _pendingCamera;
  bool _offerAreaSearch = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final selectedId = ref.watch(selectedSiteProvider);
    final mapAvailable = ref.watch(mapAvailableProvider);
    final adapter = ref.watch(mapAdapterProvider);
    final bankPreferences =
        (ref.watch(userSettingsProvider).value ?? const UserSettings())
            .bankPreferences;

    AtmSite? selectedSite;
    double? selectedDistance;
    for (final result in widget.sites) {
      if (result.site.id == selectedId) {
        selectedSite = result.site;
        selectedDistance = result.distanceMeters;
        break;
      }
    }

    final origin = widget.sites.first.site.position!;
    final sourceMarkers = [
      for (final result in widget.sites)
        if (result.site.position != null)
          MapMarker(
            siteId: result.site.id,
            position: result.site.position!,
            label: result.site.institutionName,
            selected: result.site.id == selectedId,
          ),
    ];
    final viewport = _viewportFor(sourceMarkers);
    final clustered = const MapClusterEngine(
      maxVisibleItems: 80,
    ).cluster(sourceMarkers, zoom: 15, viewport: viewport);
    final markers = [
      for (final item in clustered)
        switch (item) {
          SingleMapMarker(:final marker) => marker,
          MarkerCluster(:final stableKey, :final siteIds, :final position) =>
            MapMarker(
              siteId: stableKey,
              position: position,
              label: localizations.mapClusterLabel(siteIds.length),
              clusterSiteIds: siteIds,
            ),
        },
    ];

    final presentation = MapPresentation(
      camera: MapCameraPosition(target: selectedSite?.position ?? origin),
      markers: markers,
      selectedSiteId: selectedId,
      onMarkerSelected: (siteId) {
        for (final marker in markers) {
          if (marker.siteId == siteId && marker.isCluster) {
            _showCluster(marker.clusterSiteIds);
            return;
          }
        }
        ref.read(selectedSiteProvider.notifier).select(siteId);
      },
      onMapError: () =>
          ref.read(mapAvailableProvider.notifier).markUnavailable(),
      onCameraMoved: (camera) => setState(() {
        _pendingCamera = camera;
        _offerAreaSearch = false;
      }),
      onCameraIdle: () {
        if (_pendingCamera != null) {
          setState(() => _offerAreaSearch = true);
        }
      },
    );

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final panes = <Widget>[
              Expanded(
                child: mapAvailable
                    ? adapter.buildMap(presentation)
                    : _MapUnavailable(message: localizations.mapUnavailable),
              ),
              Expanded(
                child: _AtmList(
                  sites: widget.sites,
                  selectedId: selectedId,
                  onTapSite: (siteId) =>
                      ref.read(selectedSiteProvider.notifier).select(siteId),
                ),
              ),
            ];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    localizations.searchRadiusStraightLine(
                      (widget.radiusMeters / 1000).round(),
                    ),
                  ),
                ),
                Expanded(
                  child: AppLayout.useSideBySide(constraints)
                      ? Row(children: panes)
                      : Column(children: panes),
                ),
              ],
            );
          },
        ),
        if (_offerAreaSearch)
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(
              child: FilledButton.icon(
                onPressed: () {
                  final target = _pendingCamera?.target;
                  if (target == null) return;
                  setState(() => _offerAreaSearch = false);
                  ref.read(homeSearchProvider.notifier).searchArea(target);
                },
                icon: const Icon(Icons.search),
                label: Text(localizations.searchMapArea),
              ),
            ),
          ),
        if (selectedSite != null)
          _SummaryPanel(
            site: selectedSite,
            onViewDetails: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AtmDetailPage(
                  site: selectedSite!,
                  distanceMeters: selectedDistance,
                  bankPreferences: bankPreferences,
                ),
              ),
            ),
            onClose: () => ref.read(selectedSiteProvider.notifier).clear(),
          ),
      ],
    );
  }

  MapViewport _viewportFor(List<MapMarker> markers) {
    var south = markers.first.position.latitude;
    var north = south;
    var west = markers.first.position.longitude;
    var east = west;
    for (final marker in markers.skip(1)) {
      south = math.min(south, marker.position.latitude);
      north = math.max(north, marker.position.latitude);
      west = math.min(west, marker.position.longitude);
      east = math.max(east, marker.position.longitude);
    }
    const padding = 0.001;
    return MapViewport(
      south: south - padding,
      west: west - padding,
      north: north + padding,
      east: east + padding,
    );
  }

  Future<void> _showCluster(List<String> siteIds) async {
    final included = [
      for (final result in widget.sites)
        if (siteIds.contains(result.site.id)) result,
    ];
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final result in included)
              ListTile(
                title: Text(result.site.institutionName),
                subtitle: Text(result.site.placeName),
                onTap: () {
                  ref
                      .read(selectedSiteProvider.notifier)
                      .select(result.site.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MapUnavailable extends StatelessWidget {
  const _MapUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}

class _AtmList extends ConsumerWidget {
  const _AtmList({
    required this.sites,
    required this.selectedId,
    required this.onTapSite,
  });

  final List<NearbyAtmSite> sites;
  final String? selectedId;
  final ValueChanged<String> onTapSite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider).value ?? const [];
    final favoriteIds = {for (final favorite in favorites) favorite.site.id};
    final settings =
        ref.watch(userSettingsProvider).value ?? const UserSettings();
    final resultPolicy = ref.watch(atmResultPolicyProvider);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sites.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = sites[index];
        final site = result.site;
        return AtmResultTile(
          site: site,
          distanceMeters: result.distanceMeters,
          selected: site.id == selectedId,
          favorite: favoriteIds.contains(site.id),
          accessStatus: resultPolicy.accessStatus(site),
          bankRelationship: resultPolicy.bankRelationship(
            site,
            settings.bankPreferences,
          ),
          onSelected: () => onTapSite(site.id),
          onFavorite: () =>
              ref.read(favoritesProvider.notifier).toggle(site.id),
        );
      },
    );
  }
}

class AtmResultTile extends StatelessWidget {
  const AtmResultTile({
    required this.site,
    required this.distanceMeters,
    required this.selected,
    required this.favorite,
    required this.onSelected,
    required this.onFavorite,
    this.accessStatus = AtmAccessStatus.unknown,
    this.bankRelationship = BankRelationship.unavailable,
    super.key,
  });

  final AtmSite site;
  final double distanceMeters;
  final bool selected;
  final bool favorite;
  final VoidCallback onSelected;
  final VoidCallback onFavorite;
  final AtmAccessStatus accessStatus;
  final BankRelationship bankRelationship;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final distance = _formatDistance(localizations, distanceMeters);
    final accessLabel = accessStatusLabel(localizations, site, accessStatus);
    final accessSemantics = accessStatusSemantics(
      localizations,
      site,
      accessStatus,
    );
    final bankLabel = bankRelationshipLabel(localizations, bankRelationship);
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: selected ? colors.secondaryContainer : Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Semantics(
              key: ValueKey('atm-site-${site.id}'),
              container: true,
              button: true,
              selected: selected,
              label: [
                localizations.atmResultSemantics(
                  site.institutionName,
                  site.placeName,
                  site.displayAddress,
                  distance,
                ),
                accessSemantics,
                ?bankLabel,
              ].join('，'),
              onTap: onSelected,
              child: ExcludeSemantics(
                child: InkWell(
                  onTap: onSelected,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                site.institutionName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(site.placeName),
                              Text(site.displayAddress),
                              const SizedBox(height: 4),
                              Text(
                                accessLabel,
                                key: ValueKey('access-status-${site.id}'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (bankLabel != null)
                                Text(
                                  bankLabel,
                                  key: ValueKey('bank-context-${site.id}'),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(distance),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            key: ValueKey('list-favorite-${site.id}'),
            tooltip: favorite
                ? localizations.removeFavorite
                : localizations.addFavorite,
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
            onPressed: onFavorite,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  static String _formatDistance(
    AppLocalizations localizations,
    double distanceMeters,
  ) {
    if (distanceMeters < 1000) {
      final roundedMeters = (distanceMeters / 10).round() * 10;
      return localizations.distanceMeters(roundedMeters);
    }
    return localizations.distanceKilometers(
      (distanceMeters / 1000).toStringAsFixed(1),
    );
  }
}

/// Draggable summary for the selected ATM, pinned to the bottom.
///
/// Uses a manual vertical-drag handle rather than an animated sheet so it can
/// be resized without ever refetching results — dragging only changes this
/// widget's own height and never touches the search providers (issue #24).
class _SummaryPanel extends StatefulWidget {
  const _SummaryPanel({
    required this.site,
    required this.onViewDetails,
    required this.onClose,
  });

  final AtmSite site;
  final VoidCallback onViewDetails;
  final VoidCallback onClose;

  @override
  State<_SummaryPanel> createState() => _SummaryPanelState();
}

class _SummaryPanelState extends State<_SummaryPanel> {
  static const _minHeight = 168.0;
  static const _maxHeight = 420.0;
  double _height = 200;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final maximumHeight = math.min(
      _maxHeight,
      MediaQuery.sizeOf(context).height * 0.75,
    );
    final panelHeight = _height
        .clamp(math.min(_minHeight, maximumHeight), maximumHeight)
        .toDouble();
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Semantics(
          container: true,
          label: localizations.atmSummarySemantics(widget.site.placeName),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) => setState(() {
              _height = (_height - details.delta.dy).clamp(
                _minHeight,
                _maxHeight,
              );
            }),
            child: Container(
              key: ValueKey('atm-summary-${widget.site.id}'),
              height: panelHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(blurRadius: 8, color: Colors.black26),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.site.placeName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.site.displayAddress),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: ValueKey('atm-summary-detail-${widget.site.id}'),
                      onPressed: widget.onViewDetails,
                      child: Text(localizations.viewDetails),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogStaleBanner extends StatelessWidget {
  const _CatalogStaleBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: colors.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onErrorContainer, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(localizations.loadAtmsError),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text(localizations.retry)),
        ],
      ),
    );
  }
}
