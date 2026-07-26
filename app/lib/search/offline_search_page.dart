import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/search/recent_places.dart';
import 'package:atmfinder/search/place_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineSearchPage extends ConsumerStatefulWidget {
  const OfflineSearchPage({this.mapAreaMode = false, super.key});

  final bool mapAreaMode;

  @override
  ConsumerState<OfflineSearchPage> createState() => _OfflineSearchPageState();
}

class _OfflineSearchPageState extends ConsumerState<OfflineSearchPage> {
  final _controller = TextEditingController();
  List<AtmSite>? _results;
  List<RecentPlace> _recentPlaces = const [];
  PlaceResolution? _placeResolution;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadRecentPlaces);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mapAreaMode
              ? localizations.searchMapArea
              : localizations.manualSearch,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const ValueKey('offline-search-field'),
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: localizations.offlineSearchHint,
                suffixIcon: IconButton(
                  tooltip: localizations.search,
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_controller.text),
                ),
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: switch ((_loading, _results, _placeResolution)) {
              (true, _, _) => const Center(child: CircularProgressIndicator()),
              (false, null, _) => _RecentPlacesView(
                places: _recentPlaces,
                onSelect: _reuseRecentPlace,
                onDelete: _deleteRecentPlace,
                onClear: _clearRecentPlaces,
              ),
              (false, final results?, PlaceCandidates(:final values))
                  when results.isEmpty =>
                _PlaceCandidatesView(
                  values: values,
                  onSelect: _selectPlaceCandidate,
                ),
              (false, final results?, PlaceOutsideTaiwanUnsupported())
                  when results.isEmpty =>
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      localizations.placeOutsideTaiwanUnsupported,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              (false, final results?, _) when results.isEmpty => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _placeResolution is PlaceResolverUnavailable
                        ? localizations.placeResolverUnavailable
                        : localizations.offlinePlaceNeedsConnection,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              (false, final results?, _) => ListView.separated(
                itemCount: results.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final site = results[index];
                  return ListTile(
                    key: ValueKey('offline-result-${site.id}'),
                    onTap: () => _saveSelectedResult(site),
                    title: Text(site.institutionName),
                    subtitle: Text('${site.placeName}\n${site.displayAddress}'),
                    isThreeLine: true,
                  );
                },
              ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }
    setState(() => _loading = true);
    final results = await ref
        .read(atmCatalogProvider)
        .searchOffline(normalized);
    final resolution = results.isEmpty
        ? await ref.read(placeSearchCoordinatorProvider).resolve(normalized)
        : null;
    if (mounted) {
      setState(() {
        _loading = false;
        _results = results;
        _placeResolution = resolution;
      });
    }
  }

  Future<void> _selectPlaceCandidate(PlaceCandidate candidate) async {
    setState(() => _loading = true);
    final nearby = await ref
        .read(placeSearchCoordinatorProvider)
        .select(candidate);
    await _loadRecentPlaces();
    if (mounted) {
      setState(() {
        _loading = false;
        _placeResolution = null;
        _results = nearby.map((result) => result.site).toList(growable: false);
      });
    }
  }

  Future<void> _saveSelectedResult(AtmSite site) async {
    final label = _controller.text.trim();
    final position = site.position;
    if (label.isEmpty || position == null) {
      return;
    }
    await ref
        .read(recentPlacesRepositoryProvider)
        .save(
          RecentPlace(
            label: label,
            position: position,
            searchedAt: DateTime.now().toUtc(),
          ),
        );
    await _loadRecentPlaces();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).recentPlaceSaved)),
      );
    }
  }

  Future<void> _reuseRecentPlace(RecentPlace place) async {
    _controller.text = place.label;
    setState(() => _loading = true);
    final nearby = await ref
        .read(atmCatalogProvider)
        .findNearby(place.position, radiusMeters: 10000, limit: 50);
    if (mounted) {
      setState(() {
        _loading = false;
        _results = nearby.map((result) => result.site).toList(growable: false);
      });
    }
  }

  Future<void> _loadRecentPlaces() async {
    final places = await ref.read(recentPlacesRepositoryProvider).list();
    if (mounted) {
      setState(() => _recentPlaces = places);
    }
  }

  Future<void> _deleteRecentPlace(String label) async {
    await ref.read(recentPlacesRepositoryProvider).delete(label);
    await _loadRecentPlaces();
  }

  Future<void> _clearRecentPlaces() async {
    await ref.read(recentPlacesRepositoryProvider).clear();
    await _loadRecentPlaces();
  }
}

class _PlaceCandidatesView extends StatelessWidget {
  const _PlaceCandidatesView({required this.values, required this.onSelect});

  final List<PlaceCandidate> values;
  final ValueChanged<PlaceCandidate> onSelect;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            localizations.choosePlace,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final candidate in values)
          ListTile(
            key: ValueKey('place-candidate-${candidate.label}'),
            leading: const Icon(Icons.place_outlined),
            title: Text(candidate.label),
            onTap: () => onSelect(candidate),
          ),
      ],
    );
  }
}

class _RecentPlacesView extends StatelessWidget {
  const _RecentPlacesView({
    required this.places,
    required this.onSelect,
    required this.onDelete,
    required this.onClear,
  });

  final List<RecentPlace> places;
  final ValueChanged<RecentPlace> onSelect;
  final ValueChanged<String> onDelete;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (places.isEmpty) {
      return Center(child: Text(localizations.offlineSearchPrompt));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  localizations.recentPlaces,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: onClear,
                child: Text(localizations.clearAll),
              ),
            ],
          ),
        ),
        for (final place in places)
          ListTile(
            key: ValueKey('recent-place-${place.label}'),
            onTap: () => onSelect(place),
            leading: const Icon(Icons.history),
            title: Text(place.label),
            trailing: IconButton(
              key: ValueKey('delete-recent-${place.label}'),
              tooltip: localizations.deleteRecentPlace,
              icon: const Icon(Icons.close),
              onPressed: () => onDelete(place.label),
            ),
          ),
      ],
    );
  }
}
