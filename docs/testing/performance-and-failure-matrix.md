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

The committed report is a CI-host proxy, not evidence from the minimum Android
device. Before release, rerun on Android 10 hardware with 2 GB RAM and record
model, SoC, storage state, build mode, OS patch, and thermal state in a new
immutable report.

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
| Disk full / SQLite I/O failure | Physical-device fault injection | Verified catalog is not deleted |

Disk-full remains a device-level release check because desktop and in-memory
SQLite do not faithfully emulate Android filesystem allocation failure.
