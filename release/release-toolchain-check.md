# Release toolchain check

Date: 2026-07-26

Status: superseded by the 2026-07-26 first-release decision to omit Firebase
and Crashlytics. This historical unsigned artifact must not be uploaded; the
submit-ready candidate must be rebuilt from the current source.

This check verifies the local Android release toolchain without creating,
reading or substituting a production upload key.

## Command

```powershell
flutter build appbundle --release `
  --build-name=1.0.0 `
  --build-number=1 `
  --obfuscate `
  --split-debug-info=../release-artifacts/toolchain-check/symbols `
  --dart-define=ATM_SUPPORT_EMAIL=build-check@example.invalid
```

## Result

- Gradle `bundleRelease`: passed.
- R8, resource shrinking and Dart obfuscation: passed.
- AAB size: 55,397,543 bytes.
- SHA-256:
  `b459dc0ffad52778e5efc855e738e59835a73834778578b023542d5239c362cb`.
- `mapping.txt`: generated.
- Packaged manifest: min SDK 24, target SDK 36.
- Packaged manifest at the time of this historical check declared
  `firebase_crashlytics_collection_enabled=false`; current release source
  contains no Firebase configuration.
- `jarsigner -verify`: `jar is unsigned`.

The generated AAB is only toolchain evidence and must not be uploaded to Play.
The submit-ready candidate must be rebuilt by `scripts/build-release.ps1` or
the protected release workflow after the owner injects the real upload
keystore, restricted Maps key, support email, production quality report and
Android minimum-tier report.
