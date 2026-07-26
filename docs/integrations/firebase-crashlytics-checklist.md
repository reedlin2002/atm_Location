# Firebase Crashlytics owner checklist

This checklist intentionally contains no project IDs, secrets, service
accounts, or writable credentials.

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
