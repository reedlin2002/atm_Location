# Google Platform key setup

The repository contains no Maps or Places credential. Android builds read
`MAPS_API_KEY` from an environment variable or Gradle property and inject it
through the `MAPS_API_KEY` manifest placeholder. A blank value must leave the
list and detail journey usable while the map reports unavailable.

Owner steps:

1. Rotate the key that was previously present in the local manifest. Treat it
   as exposed even if no public commit is known.
2. Use a dedicated Google Cloud project for ATM Finder.
3. Create a Maps SDK for Android key restricted to
   `com.reedlin2002.atmfinder` and every approved debug/release signing SHA-1
   and SHA-256 certificate. Restrict API access to Maps SDK for Android.
4. If online place resolution is enabled, use a separate key and provider
   adapter. Apply the narrowest platform/API restrictions, quotas, billing
   alerts, and Taiwan-only product behavior. Never reuse a server key in the
   Android client.
5. Inject keys through local environment or CI secrets. Do not write them to
   `AndroidManifest.xml`, Dart source, fixtures, logs, screenshots, issues, or
   release metadata.
6. Verify debug and signed release builds separately: map loads with the
   expected certificate, an intentionally wrong certificate is rejected, and
   blank/missing keys degrade to the linked ATM list.
7. Save dated Cloud Console screenshots showing application/API restrictions,
   quota and billing alerts, without displaying the credential value.
