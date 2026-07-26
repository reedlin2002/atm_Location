# ATM Finder performance gate

- Dataset: `production-like-2026.07.26`
- Device profile: `ci-host-proxy; Android 10 / 2 GB device integration rerun required`
- OS: `windows "Windows 11 家用版" 10.0 (Build 26200)`
- Runtime: `3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "windows_x64"`
- Coordinate coverage: 99.00%
- Compressed bytes: 454914

| Metric | Samples | p50 (ms) | p95 (ms) |
|---|---:|---:|---:|
| firstImport | 3 | 1547.59 | 1972.39 |
| warmStart | 30 | 0.30 | 0.45 |
| nearbyQuery | 60 | 1.81 | 3.75 |
| textSearch | 30 | 24.42 | 26.89 |

**Status: PASSED**
