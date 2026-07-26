# Performance and failure matrix

## Reproducible host gate

Run from `app/`:

```powershell
flutter test test/production_performance_gate_test.dart
```

The test deterministically generates 25,000 Taiwan-shaped ATM rows, keeps 99%
coordinate coverage, imports the artifact contract through the real Drift
importer, and records first import, warm start, nearby query, and text search
samples. It writes machine-readable JSON and Markdown under
`performance/reports/`.

Hard limits are centralized in `lib/quality/performance_gate.dart`: coordinate
coverage >= 98%, gzip <= 10 MiB, full import p95 <= 5,000 ms, warm start p95
<= 2,000 ms, and nearby query p95 <= 300 ms. A threshold change requires a
separate product decision; CI must not compensate by changing data or silently
widening a limit.

## Reproducible Android minimum-tier gate

The automated minimum tier is fixed as Android 10/API 29, two emulator cores,
2 GB RAM and x86_64. Start that AVD, then run from the repository root:

```powershell
.\scripts\run-android10-performance.ps1 `
  -DeviceId emulator-5554 `
  -FlutterCommand flutter
```

The runner rejects the wrong API, memory outside the 2 GB tier, a non-Android
Dart runtime, missing report output, or any gate violation. It saves JSON,
Markdown and the full test transcript under `performance/reports/`. The
integration test asserts `Platform.isAndroid`, so a desktop `flutter test -d`
run cannot masquerade as device evidence.

`.github/workflows/android-minimum-tier.yml` recreates the same API 29,
two-core, 2048 MB AVD without Google or Firebase keys and publishes the three
reports as an artifact. A physical low-end-device pass remains useful release
confidence and is part of the owner journey, but is not substituted for this
fixed, reproducible regression baseline.

## Failure matrix

| Failure | Automated evidence | Required invariant |
|---|---|---|
| Source missing/schema changed | `pipeline/tests/test_fisc_national_atm_adapter.py` | Build fails; no publication |
| Coordinate coverage below 98% | `pipeline/tests/test_publication_gate.py` | Publication blocked; unresolved distribution retained |
| Snapshot over 10 MiB | `pipeline/tests/test_publication_gate.py` | Publication blocked |
| Checksum/schema mismatch | publication tests and `app/test/catalog_artifact_contract_test.dart` | Installed catalog unchanged |
| Network interruption | `app/test/catalog_update_test.dart` | Last verified catalog remains searchable |
| Delta failure | `app/test/catalog_delta_test.dart` | Transaction rolls back |
| Rollback after bad update | `app/test/catalog_rollback_test.dart` | Prior snapshot restored |
| Duplicate surge | publication contract and >2% approval tests | Block or explicit human approval |
| Dense map input | `app/test/map_clustering_test.dart` | Bounded deterministic marker output |
| Disk full / SQLite I/O failure | `app/test/catalog_artifact_contract_test.dart` injects SQLite `database or disk is full` during replacement | Batch rollback retains the verified catalog; physical fault injection remains an owner smoke check |

Disk-full remains a device-level release check because desktop and in-memory
SQLite do not faithfully emulate Android filesystem allocation failure.
