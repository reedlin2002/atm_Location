# ATM Finder Android performance gate

- Dataset: `production-like-2026.07.26`
- Device profile: `Android 10/API 29; MemTotal 2040256 kB; Android SDK built for x86_64; x86_64`
- OS: `android sdk_gphone_x86_64-userdebug 10 QSR1.211112.011 13135432 dev-keys`
- Runtime: `3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "android_x64"`
- Coordinate coverage: 99.00%
- Compressed bytes: 454914

| Metric | Samples | p50 (ms) | p95 (ms) |
|---|---:|---:|---:|
| firstImport | 3 | 1295.651 | 1893.048 |
| warmStart | 30 | 0.297 | 0.907 |
| nearbyQuery | 60 | 2.114 | 5.669 |
| textSearch | 30 | 17.146 | 21.466 |

**Status: PASSED**
