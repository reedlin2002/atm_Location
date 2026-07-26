import 'package:atmfinder/catalog/atm_database.dart';

class CrashDiagnosticReport {
  const CrashDiagnosticReport({
    required this.fatal,
    required this.errorType,
    required this.stackTrace,
    required this.metadata,
  });

  final bool fatal;
  final String errorType;
  final String stackTrace;
  final Map<String, Object> metadata;
}

abstract interface class CrashDiagnosticsProvider {
  Future<void> initialize();

  Future<void> record(CrashDiagnosticReport report);

  Future<void> clearPending();
}

abstract interface class DiagnosticsConsentRepository {
  Future<bool> isEnabled();

  Future<void> setEnabled(bool enabled);
}

class DriftDiagnosticsConsentRepository
    implements DiagnosticsConsentRepository {
  const DriftDiagnosticsConsentRepository(this._database);

  static const _key = 'diagnostics.consent.v1';

  final AtmDatabase _database;

  @override
  Future<bool> isEnabled() async {
    final row = await (_database.select(
      _database.appPreferences,
    )..where((preference) => preference.key.equals(_key))).getSingleOrNull();
    return row?.value == 'true';
  }

  @override
  Future<void> setEnabled(bool enabled) {
    return _database
        .into(_database.appPreferences)
        .insertOnConflictUpdate(
          AppPreferencesCompanion.insert(key: _key, value: enabled.toString()),
        );
  }
}

class CrashDiagnosticsBoundary {
  CrashDiagnosticsBoundary({required this.consent, required this.provider});

  static const allowedMetadataKeys = {
    'appVersion',
    'buildNumber',
    'os',
    'osVersion',
    'deviceClass',
    'catalogVersion',
    'errorCode',
    'operation',
  };

  final DiagnosticsConsentRepository consent;
  final CrashDiagnosticsProvider? provider;
  bool _providerReady = false;

  Future<void> setEnabled(bool enabled) async {
    await consent.setEnabled(enabled);
    if (enabled) {
      return;
    }
    _providerReady = false;
    try {
      await provider?.clearPending();
    } on Object {
      // Diagnostics must never affect the core app.
    }
  }

  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> metadata = const {},
  }) {
    return _record(
      fatal: true,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> metadata = const {},
  }) {
    return _record(
      fatal: false,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  Future<void> _record({
    required bool fatal,
    required Object error,
    required StackTrace stackTrace,
    required Map<String, Object?> metadata,
  }) async {
    if (!await consent.isEnabled() || !await _ensureProviderReady()) {
      return;
    }
    final report = CrashDiagnosticReport(
      fatal: fatal,
      errorType: error.runtimeType.toString(),
      stackTrace: _truncate(stackTrace.toString(), 8000),
      metadata: _sanitize(metadata),
    );
    try {
      await provider!.record(report);
    } on Object {
      // Diagnostics must never affect the core app.
    }
  }

  Future<bool> _ensureProviderReady() async {
    if (provider == null) {
      return false;
    }
    if (_providerReady) {
      return true;
    }
    try {
      await provider!.initialize();
      _providerReady = true;
      return true;
    } on Object {
      return false;
    }
  }

  static Map<String, Object> _sanitize(Map<String, Object?> raw) {
    final sanitized = <String, Object>{};
    for (final entry in raw.entries) {
      if (!allowedMetadataKeys.contains(entry.key)) {
        continue;
      }
      final value = entry.value;
      if (value is String) {
        sanitized[entry.key] = _truncate(value, 120);
      } else if (value is num || value is bool) {
        sanitized[entry.key] = value as Object;
      }
    }
    return Map.unmodifiable(sanitized);
  }

  static String _truncate(String value, int maximumLength) {
    if (value.length <= maximumLength) {
      return value;
    }
    return value.substring(0, maximumLength);
  }
}
