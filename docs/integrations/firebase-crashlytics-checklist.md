# Deferred Firebase Crashlytics checklist

First-release decision (2026-07-26): ATM Finder does not include Firebase,
Crashlytics, Analytics, advertising SDKs or a diagnostics setting. No Firebase
project or credential should be created for version 1.0.0.

This future-only checklist intentionally contains no project IDs, secrets,
service accounts, or writable credentials. It may be used only after a later
product and privacy review explicitly restores crash diagnostics.

## Dormant repository boundary

- `CrashDiagnosticsBoundary` keeps the provider behind persisted opt-in and a
  fixed allowlist; provider absence or failure cannot block the core flow.
- Release code does not expose the diagnostics setting and does not include
  Firebase Core, Crashlytics or Analytics dependencies or native configuration.

## Future owner configuration

1. Create a project dedicated to ATM Finder and register the exact release
   Android application ID.
2. Decline Google Analytics and leave advertising and behavioral tracking
   disabled.
3. Add only the Firebase/Crashlytics Android configuration and build plugins
   recommended for the pinned Flutter/Android toolchain.
4. Implement `CrashDiagnosticsProvider` behind `CrashDiagnosticsBoundary`;
   never call an SDK directly from UI or domain code.
5. Keep automatic collection disabled at SDK startup. Enable it only after the
   persisted opt-in gate is true.
6. Map only the boundary allowlist to custom keys. Never add coordinates,
   queries, recent places, favorites, selected ATM IDs, advertising IDs, or
   behavior events.
7. On a real release-build device, trigger a test crash before consent and
   verify no event appears after the console processing window.
8. Opt in, trigger a distinguishable test crash, and verify it appears with
   only allowlisted keys. Opt out and verify pending local reports are cleared.
9. Record retention and data-processing settings for the privacy policy and
   Play Data safety answers.
10. Attach dated console screenshots and device results to Issue 29 without
    copying secret values.

Use the official `flutterfire configure` workflow only after steps 1–2 are
confirmed. Re-run it after adding `firebase_core` and `firebase_crashlytics` so
the generated options and Android Crashlytics Gradle plugin match the selected
project. Do not add `firebase_analytics`; breadcrumb logs are intentionally
excluded because this product does not collect behavior analytics.
