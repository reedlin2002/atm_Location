# ATM Finder performance gate

- Dataset: `production-like-2026.07.26`
- Device profile: `ci-host-proxy; Android 10 / 2 GB physical-device rerun required`
- OS: `windows "Windows 11 家用版" 10.0 (Build 26200)`
- Runtime: `3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "windows_x64"`
- Coordinate coverage: 99.00%
- Compressed bytes: 454914

| Metric | Samples | p50 (ms) | p95 (ms) |
|---|---:|---:|---:|
| firstImport | 3 | 1872.88 | 2528.55 |
| warmStart | 30 | 0.49 | 0.71 |
| nearbyQuery | 60 | 2.54 | 4.38 |
| textSearch | 30 | 37.30 | 42.21 |

**Status: PASSED**
