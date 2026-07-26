import 'package:atmfinder/app_dependencies.dart';
import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/external/external_actions.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/l10n/result_context_labels.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AtmDetailPage extends ConsumerWidget {
  const AtmDetailPage({
    required this.site,
    this.distanceMeters,
    this.retired = false,
    this.bankPreferences = const BankPreferences(),
    this.showFavoriteAction = true,
    super.key,
  });

  final AtmSite site;
  final double? distanceMeters;
  final bool retired;
  final BankPreferences bankPreferences;
  final bool showFavoriteAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context);
    final snapshot = ref.watch(catalogSnapshotProvider);
    final isStale = ref.watch(catalogIsStaleProvider);
    final isFavorite =
        showFavoriteAction &&
        (ref.watch(favoritesProvider).value ?? const []).any(
          (favorite) => favorite.site.id == site.id,
        );
    final resultPolicy = ref.watch(atmResultPolicyProvider);
    final accessStatus = resultPolicy.accessStatus(site);
    final bankRelationship = resultPolicy.bankRelationship(
      site,
      bankPreferences,
    );
    final bankLabel = bankRelationshipLabel(localizations, bankRelationship);

    return Scaffold(
      appBar: AppBar(
        title: Text(site.institutionName),
        actions: [
          if (showFavoriteAction)
            IconButton(
              key: ValueKey('favorite-toggle-${site.id}'),
              tooltip: isFavorite
                  ? localizations.removeFavorite
                  : localizations.addFavorite,
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).toggle(site.id),
            ),
        ],
      ),
      body: SingleChildScrollView(
        key: ValueKey('atm-detail-${site.id}'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (retired)
              _StaleWarning(message: localizations.retiredFavoriteWarning),
            if (isStale.value == true)
              _StaleWarning(message: localizations.staleDataWarning),

            Text(site.placeName, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(site.displayAddress, style: textTheme.bodyLarge),
            if (site.county.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(site.county, style: textTheme.bodyMedium),
            ],
            if (distanceMeters case final distance?) ...[
              const SizedBox(height: 4),
              Text(
                localizations.detailDistanceLabel(
                  _formatDistance(localizations, distance),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              accessStatusLabel(localizations, site, accessStatus),
              key: ValueKey('detail-access-status-${site.id}'),
            ),
            if (bankLabel != null) ...[
              const SizedBox(height: 4),
              Text(bankLabel, key: ValueKey('detail-bank-context-${site.id}')),
              const SizedBox(height: 4),
              Text(localizations.bankFeeDisclaimer, style: textTheme.bodySmall),
            ],

            const SizedBox(height: 16),
            Text(
              localizations.placeCategoryLabel(
                _placeCategoryLabel(localizations, site.placeCategory),
              ),
            ),
            if (site.placeCategoryEvidence case final evidence?) ...[
              const SizedBox(height: 4),
              Text(
                localizations.placeCategoryEvidenceSourceLabel(
                  _publisherLabel(localizations, evidence.publisher),
                ),
              ),
            ],
            if (site.coordinateEvidence case final evidence?) ...[
              const SizedBox(height: 4),
              Text(
                localizations.coordinateEvidenceSourceLabel(
                  _publisherLabel(localizations, evidence.publisher),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizations.evidenceDateLabel(_isoDate(evidence.sourceDate)),
              ),
              const SizedBox(height: 4),
              Text(
                localizations.evidenceConfidenceLabel(
                  _confidenceLabel(localizations, evidence.confidence),
                ),
              ),
            ],

            const SizedBox(height: 16),
            for (final capability in AtmCapability.values) ...[
              Text(
                localizations.capabilityLabel(
                  _capabilityLabel(localizations, capability),
                  _capabilityStatusLabel(
                    localizations,
                    site.capabilityStatus(capability),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: ValueKey('navigate-${site.id}'),
                  icon: const Icon(Icons.directions),
                  label: Text(localizations.navigateToAtm),
                  onPressed: () => _runExternalAction(
                    context,
                    ref.read(externalActionsControllerProvider).navigate(site),
                    localizations,
                  ),
                ),
                OutlinedButton.icon(
                  key: ValueKey('share-${site.id}'),
                  icon: const Icon(Icons.share),
                  label: Text(localizations.shareAtm),
                  onPressed: () => _runExternalAction(
                    context,
                    ref.read(externalActionsControllerProvider).shareAtm(site),
                    localizations,
                  ),
                ),
                OutlinedButton.icon(
                  key: ValueKey('report-${site.id}'),
                  icon: const Icon(Icons.report_outlined),
                  label: Text(localizations.reportAtmData),
                  onPressed: () => _runExternalAction(
                    context,
                    ref
                        .read(externalActionsControllerProvider)
                        .reportAtm(
                          site,
                          datasetVersion:
                              snapshot.value?.datasetVersion ?? 'unknown',
                        ),
                    localizations,
                  ),
                ),
              ],
            ),

            snapshot.when(
              data: (meta) {
                if (meta == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      localizations.catalogVersionLabel(meta.datasetVersion),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.catalogRefreshedAtLabel(
                        _isoDate(meta.lastRefreshedAt),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDistance(AppLocalizations localizations, double meters) {
    if (meters < 1000) {
      final rounded = (meters / 10).round() * 10;
      return localizations.distanceMeters(rounded);
    }
    return localizations.distanceKilometers((meters / 1000).toStringAsFixed(1));
  }

  static Future<void> _runExternalAction(
    BuildContext context,
    Future<ExternalActionOutcome> action,
    AppLocalizations localizations,
  ) async {
    final outcome = await action;
    if (!context.mounted || outcome == ExternalActionOutcome.launched) {
      return;
    }
    final message = switch (outcome) {
      ExternalActionOutcome.unavailable =>
        localizations.externalActionUnavailable,
      ExternalActionOutcome.copiedFallback => localizations.supportEmailCopied,
      ExternalActionOutcome.launched => '',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  static String _publisherLabel(
    AppLocalizations localizations,
    EvidencePublisher publisher,
  ) {
    return switch (publisher) {
      EvidencePublisher.fisc => localizations.evidencePublisherFisc,
      EvidencePublisher.ministryOfDigitalAffairs =>
        localizations.evidencePublisherMinistryOfDigitalAffairs,
      EvidencePublisher.chunghwaPost =>
        localizations.evidencePublisherChunghwaPost,
      EvidencePublisher.licensedGeocoder =>
        localizations.evidencePublisherLicensedGeocoder,
      EvidencePublisher.manualReview =>
        localizations.evidencePublisherManualReview,
      EvidencePublisher.unknown => localizations.evidencePublisherUnknown,
    };
  }

  static String _confidenceLabel(
    AppLocalizations localizations,
    EvidenceConfidence confidence,
  ) {
    return switch (confidence) {
      EvidenceConfidence.officialExact =>
        localizations.evidenceConfidenceOfficialExact,
      EvidenceConfidence.officialPositive =>
        localizations.evidenceConfidenceOfficialPositive,
      EvidenceConfidence.licensedExact =>
        localizations.evidenceConfidenceLicensedExact,
      EvidenceConfidence.licensedFuzzy =>
        localizations.evidenceConfidenceLicensedFuzzy,
      EvidenceConfidence.manualReviewed =>
        localizations.evidenceConfidenceManualReviewed,
      EvidenceConfidence.unknown => localizations.evidenceConfidenceUnknown,
    };
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

  static String _capabilityStatusLabel(
    AppLocalizations localizations,
    CapabilityStatus status,
  ) {
    return switch (status) {
      CapabilityStatus.confirmed => localizations.capabilityStatusConfirmed,
      CapabilityStatus.unknown => localizations.capabilityStatusUnknown,
      CapabilityStatus.unsupported => localizations.capabilityStatusUnsupported,
    };
  }

  static String _isoDate(DateTime value) {
    final utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }
}

class _StaleWarning extends StatelessWidget {
  const _StaleWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
