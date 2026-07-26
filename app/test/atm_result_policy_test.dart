import 'package:atmfinder/catalog/atm_catalog.dart';
import 'package:atmfinder/location/location_gateway.dart';
import 'package:atmfinder/search/atm_result_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('存款篩選只保留已確認支援的 ATM', () {
    final results = [
      _result('confirmed', CapabilityStatus.confirmed, 100),
      _result('unknown', CapabilityStatus.unknown, 50),
      _result('unsupported', CapabilityStatus.unsupported, 25),
    ];

    final filtered = const AtmResultPolicy().apply(
      results,
      filters: const AtmFilters(requiredCapabilities: {AtmCapability.deposit}),
    );

    expect(filtered.map((result) => result.site.id), ['confirmed']);
  });

  test('銀行代碼與場所類型使用 canonical values 組合篩選', () {
    final results = [
      _result(
        'bank',
        CapabilityStatus.confirmed,
        100,
        institutionCode: '004',
        category: PlaceCategory.bank,
      ),
      _result(
        'store',
        CapabilityStatus.confirmed,
        50,
        institutionCode: '004',
        category: PlaceCategory.convenienceStore,
      ),
      _result(
        'other-bank',
        CapabilityStatus.confirmed,
        25,
        institutionCode: '812',
        category: PlaceCategory.bank,
      ),
    ];

    final filtered = const AtmResultPolicy().apply(
      results,
      filters: const AtmFilters(
        institutionCodes: {'004'},
        placeCategories: {PlaceCategory.bank},
      ),
    );

    expect(filtered.map((result) => result.site.id), ['bank']);
  });

  test('同距離時依目前可進入、未知、關閉排序', () {
    final results = [
      _result(
        'closed',
        CapabilityStatus.unknown,
        100,
        accessSchedule: const AtmAccessSchedule(
          periods: [
            AccessPeriod(
              weekday: DateTime.monday,
              startMinute: 300,
              endMinute: 360,
            ),
          ],
        ),
      ),
      _result('unknown', CapabilityStatus.unknown, 100),
      _result(
        'open',
        CapabilityStatus.unknown,
        100,
        accessSchedule: const AtmAccessSchedule(
          periods: [
            AccessPeriod(
              weekday: DateTime.monday,
              startMinute: 0,
              endMinute: 300,
            ),
          ],
        ),
      ),
    ];

    final ordered = AtmResultPolicy(
      clock: FixedAtmClock(DateTime.utc(2026, 7, 26, 18)),
    ).apply(results);

    expect(ordered.map((result) => result.site.id), [
      'open',
      'unknown',
      'closed',
    ]);
  });

  test('跨午夜時段的隔日部分仍可被目前營業篩選命中', () {
    final results = [
      _result(
        'overnight',
        CapabilityStatus.unknown,
        100,
        accessSchedule: const AtmAccessSchedule(
          periods: [
            AccessPeriod(
              weekday: DateTime.monday,
              startMinute: 1320,
              endMinute: 120,
            ),
          ],
        ),
      ),
      _result('unknown', CapabilityStatus.unknown, 50),
    ];

    final filtered = AtmResultPolicy(
      clock: FixedAtmClock(DateTime.utc(2026, 7, 27, 17)),
    ).apply(results, filters: const AtmFilters(openNowOnly: true));

    expect(filtered.map((result) => result.site.id), ['overnight']);
  });

  test('常用銀行只在使用者明確啟用同銀行優先後提升', () {
    final results = [
      _result(
        'preferred-far',
        CapabilityStatus.unknown,
        500,
        institutionCode: '004',
      ),
      _result(
        'other-near',
        CapabilityStatus.unknown,
        100,
        institutionCode: '812',
      ),
    ];

    final defaultOrder = const AtmResultPolicy().apply(
      results,
      bankPreferences: const BankPreferences(
        preferredInstitutionCodes: {'004'},
      ),
    );
    final preferredOrder = const AtmResultPolicy().apply(
      results,
      bankPreferences: const BankPreferences(
        preferredInstitutionCodes: {'004'},
        preferSameBank: true,
      ),
    );

    expect(defaultOrder.map((result) => result.site.id), [
      'other-near',
      'preferred-far',
    ]);
    expect(preferredOrder.map((result) => result.site.id), [
      'preferred-far',
      'other-near',
    ]);
  });

  test('本行與跨行 context 只用主要銀行的 canonical institution code', () {
    final policy = const AtmResultPolicy();
    final sameBank = _result(
      'same-bank',
      CapabilityStatus.unknown,
      100,
      institutionCode: '004',
    ).site;
    final crossBank = _result(
      'cross-bank',
      CapabilityStatus.unknown,
      100,
      institutionCode: '812',
    ).site;
    const preferences = BankPreferences(primaryInstitutionCode: '004');

    expect(
      policy.bankRelationship(sameBank, preferences),
      BankRelationship.sameBank,
    );
    expect(
      policy.bankRelationship(crossBank, preferences),
      BankRelationship.crossBank,
    );
    expect(
      policy.bankRelationship(sameBank, const BankPreferences()),
      BankRelationship.unavailable,
    );
  });

  test('public access result keeps missing schedule as unknown', () {
    final site = _result(
      'unknown-access',
      CapabilityStatus.unknown,
      100,
      category: PlaceCategory.convenienceStore,
    ).site;

    expect(const AtmResultPolicy().accessStatus(site), AtmAccessStatus.unknown);
  });
}

NearbyAtmSite _result(
  String id,
  CapabilityStatus status,
  double distanceMeters, {
  String institutionCode = '004',
  PlaceCategory category = PlaceCategory.bank,
  AtmAccessSchedule? accessSchedule,
}) {
  return NearbyAtmSite(
    site: AtmSite(
      id: id,
      institutionCode: institutionCode,
      institutionName: '臺灣銀行',
      placeName: '測試據點',
      placeCategory: category,
      displayAddress: '臺北市中正區測試路 1 號',
      position: const GeoPoint(latitude: 25.04, longitude: 121.51),
      capabilities: [
        CapabilityFact(capability: AtmCapability.deposit, status: status),
      ],
      accessSchedule: accessSchedule,
    ),
    distanceMeters: distanceMeters,
  );
}
