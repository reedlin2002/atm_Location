import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/l10n/app_localizations.dart';
import 'package:atmfinder/search/atm_result_policy.dart';

String accessStatusValue(
  AppLocalizations localizations,
  AtmSite site,
  AtmAccessStatus status,
) {
  if (site.accessSchedule?.confirmedTwentyFourHours == true) {
    return localizations.accessStatusTwentyFourHours;
  }
  return switch (status) {
    AtmAccessStatus.open => localizations.accessStatusOpen,
    AtmAccessStatus.unknown => localizations.accessStatusUnknown,
    AtmAccessStatus.closed => localizations.accessStatusClosed,
  };
}

String accessStatusLabel(
  AppLocalizations localizations,
  AtmSite site,
  AtmAccessStatus status,
) {
  return localizations.accessStatusLabel(
    accessStatusValue(localizations, site, status),
  );
}

String accessStatusSemantics(
  AppLocalizations localizations,
  AtmSite site,
  AtmAccessStatus status,
) {
  return localizations.accessStatusSemantics(
    accessStatusValue(localizations, site, status),
  );
}

String? bankRelationshipLabel(
  AppLocalizations localizations,
  BankRelationship relationship,
) {
  return switch (relationship) {
    BankRelationship.sameBank => localizations.bankRelationshipSame,
    BankRelationship.crossBank => localizations.bankRelationshipCross,
    BankRelationship.unavailable => null,
  };
}
