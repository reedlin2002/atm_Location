import 'package:atmfinder/catalog/atm_catalog.dart';

class AtmFilters {
  const AtmFilters({
    this.institutionCodes = const {},
    this.placeCategories = const {},
    this.requiredCapabilities = const {},
    this.openNowOnly = false,
    this.twentyFourHoursOnly = false,
  });

  final Set<String> institutionCodes;
  final Set<PlaceCategory> placeCategories;
  final Set<AtmCapability> requiredCapabilities;
  final bool openNowOnly;
  final bool twentyFourHoursOnly;

  bool get isEmpty =>
      institutionCodes.isEmpty &&
      placeCategories.isEmpty &&
      requiredCapabilities.isEmpty &&
      !openNowOnly &&
      !twentyFourHoursOnly;
}

class BankPreferences {
  const BankPreferences({
    this.preferredInstitutionCodes = const {},
    this.primaryInstitutionCode,
    this.preferSameBank = false,
  });

  final Set<String> preferredInstitutionCodes;
  final String? primaryInstitutionCode;
  final bool preferSameBank;
}

enum BankRelationship { sameBank, crossBank, unavailable }

class AtmResultPolicy {
  const AtmResultPolicy({this.clock = const SystemAtmClock()});

  final AtmClock clock;

  List<NearbyAtmSite> apply(
    Iterable<NearbyAtmSite> results, {
    AtmFilters filters = const AtmFilters(),
    BankPreferences bankPreferences = const BankPreferences(),
  }) {
    final eligible = results
        .where(
          (result) =>
              (filters.institutionCodes.isEmpty ||
                  filters.institutionCodes.contains(
                    result.site.institutionCode,
                  )) &&
              (filters.placeCategories.isEmpty ||
                  filters.placeCategories.contains(
                    result.site.placeCategory,
                  )) &&
              filters.requiredCapabilities.every(
                (capability) =>
                    result.site.capabilityStatus(capability) ==
                    CapabilityStatus.confirmed,
              ) &&
              (!filters.openNowOnly ||
                  accessStatus(result.site) == AtmAccessStatus.open) &&
              (!filters.twentyFourHoursOnly ||
                  result.site.accessSchedule?.confirmedTwentyFourHours == true),
        )
        .toList();
    eligible.sort((left, right) {
      final accessOrder = _accessRank(
        accessStatus(left.site),
      ).compareTo(_accessRank(accessStatus(right.site)));
      if (accessOrder != 0) {
        return accessOrder;
      }
      if (bankPreferences.preferSameBank) {
        final bankOrder = _bankRank(
          left.site,
          bankPreferences,
        ).compareTo(_bankRank(right.site, bankPreferences));
        if (bankOrder != 0) {
          return bankOrder;
        }
      }
      final distanceOrder = left.distanceMeters.compareTo(right.distanceMeters);
      if (distanceOrder != 0) {
        return distanceOrder;
      }
      return left.site.id.compareTo(right.site.id);
    });
    return List.unmodifiable(eligible);
  }

  /// Evaluates access using explicit schedule evidence and a replaceable clock.
  ///
  /// A place category or name never changes an unknown result into open.
  AtmAccessStatus accessStatus(AtmSite site) {
    final schedule = site.accessSchedule;
    if (schedule == null) {
      return AtmAccessStatus.unknown;
    }
    if (schedule.confirmedTwentyFourHours) {
      return AtmAccessStatus.open;
    }
    final local = clock.nowUtc().toUtc().add(const Duration(hours: 8));
    final minute = local.hour * 60 + local.minute;
    final isOpen = schedule.periods.any((period) {
      if (period.endMinute > period.startMinute) {
        return period.weekday == local.weekday &&
            minute >= period.startMinute &&
            minute < period.endMinute;
      }
      final followingWeekday = period.weekday == DateTime.sunday
          ? DateTime.monday
          : period.weekday + 1;
      return (period.weekday == local.weekday &&
              minute >= period.startMinute) ||
          (followingWeekday == local.weekday && minute < period.endMinute);
    });
    return isOpen ? AtmAccessStatus.open : AtmAccessStatus.closed;
  }

  /// Compares canonical institution codes against the one selected primary
  /// bank. Without a primary bank, no same/cross-bank claim is made.
  BankRelationship bankRelationship(AtmSite site, BankPreferences preferences) {
    final primaryCode = preferences.primaryInstitutionCode;
    if (primaryCode == null || primaryCode.isEmpty) {
      return BankRelationship.unavailable;
    }
    return site.institutionCode == primaryCode
        ? BankRelationship.sameBank
        : BankRelationship.crossBank;
  }

  static int _accessRank(AtmAccessStatus status) => switch (status) {
    AtmAccessStatus.open => 0,
    AtmAccessStatus.unknown => 1,
    AtmAccessStatus.closed => 2,
  };

  static int _bankRank(AtmSite site, BankPreferences preferences) =>
      preferences.preferredInstitutionCodes.contains(site.institutionCode)
      ? 0
      : 1;
}

abstract interface class AtmClock {
  DateTime nowUtc();
}

class SystemAtmClock implements AtmClock {
  const SystemAtmClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class FixedAtmClock implements AtmClock {
  const FixedAtmClock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value.toUtc();
}
