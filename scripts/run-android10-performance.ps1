param(
    [string]$DeviceId = "emulator-5554",
    [string]$FlutterCommand = "flutter",
    [string]$AndroidSdkRoot = "",
    [int]$ExpectedApi = 29,
    [int]$MinimumMemoryKb = 1900000,
    [int]$MaximumMemoryKb = 2200000
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $projectRoot "app"
$reportRoot = Join-Path $projectRoot "performance\reports"
if ([string]::IsNullOrWhiteSpace($AndroidSdkRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) {
        $AndroidSdkRoot = $env:ANDROID_SDK_ROOT
    } elseif (-not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) {
        $AndroidSdkRoot = $env:ANDROID_HOME
    } else {
        $AndroidSdkRoot = Join-Path $env:LOCALAPPDATA "Android\Sdk"
    }
}
$isWindowsPlatform = (
    [System.Environment]::OSVersion.Platform -eq
    [System.PlatformID]::Win32NT
)
$adbName = if ($isWindowsPlatform) { "adb.exe" } else { "adb" }
$adb = Join-Path $AndroidSdkRoot "platform-tools\$adbName"

if (-not (Test-Path -LiteralPath $adb)) {
    throw "adb not found at $adb"
}

$deviceState = (& $adb -s $DeviceId get-state 2>$null).Trim()
if ($deviceState -ne "device") {
    throw "Android device $DeviceId is not ready."
}

$api = [int]((& $adb -s $DeviceId shell getprop ro.build.version.sdk).Trim())
$release = (& $adb -s $DeviceId shell getprop ro.build.version.release).Trim()
$model = (& $adb -s $DeviceId shell getprop ro.product.model).Trim()
$abi = (& $adb -s $DeviceId shell getprop ro.product.cpu.abi).Trim()
$memoryLine = (& $adb -s $DeviceId shell cat /proc/meminfo |
    Select-String -Pattern "^MemTotal:" |
    Select-Object -First 1).Line
$memoryKb = [int](($memoryLine -replace "[^0-9]", ""))

if ($api -ne $ExpectedApi) {
    throw "Expected API $ExpectedApi but device reports API $api."
}
if ($memoryKb -lt $MinimumMemoryKb -or $memoryKb -gt $MaximumMemoryKb) {
    throw "Expected a 2 GB device tier; MemTotal is $memoryKb kB."
}

$deviceProfile = "Android $release/API $api; MemTotal $memoryKb kB; $model; $abi"
$flutterArguments = @(
    "test",
    "-d", $DeviceId,
    "integration_test/production_performance_gate_test.dart",
    "--no-uninstall",
    "--reporter", "expanded",
    "--dart-define=PERFORMANCE_DEVICE_PROFILE=$deviceProfile"
)

Push-Location $appRoot
try {
    $transcript = @(& $FlutterCommand @flutterArguments 2>&1)
    $exitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

$transcript | ForEach-Object { Write-Host $_ }
if ($exitCode -ne 0) {
    throw "Android performance integration test failed with exit code $exitCode."
}

$marker = "ATM_PERFORMANCE_REPORT_JSON="
$reportLine = $transcript |
    Where-Object { "$_".Contains($marker) } |
    Select-Object -Last 1
if ($null -eq $reportLine) {
    throw "The device test passed without returning a performance report."
}

$json = "$reportLine"
$json = $json.Substring($json.IndexOf($marker) + $marker.Length)
$report = $json | ConvertFrom-Json
if ($report.environment.operatingSystem -notlike "android *") {
    throw "The report did not originate from the Android runtime."
}
if ($report.status -ne "passed") {
    throw "The Android performance report contains gate violations."
}

New-Item -ItemType Directory -Path $reportRoot -Force | Out-Null
$stem = "performance-$($report.datasetVersion)-android-api$api-2gb"
$jsonPath = Join-Path $reportRoot "$stem.json"
$markdownPath = Join-Path $reportRoot "$stem.md"
$transcriptPath = Join-Path $reportRoot "$stem.log"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$prettyJson = $report | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($jsonPath, "$prettyJson`n", $utf8NoBom)

$rows = foreach ($property in $report.timings.PSObject.Properties) {
    $timing = $property.Value
    "| $($property.Name) | $($timing.sampleCount) | $($timing.p50Milliseconds) | $($timing.p95Milliseconds) |"
}
$markdown = @"
# ATM Finder Android performance gate

- Dataset: ``$($report.datasetVersion)``
- Device profile: ``$deviceProfile``
- OS: ``$($report.environment.operatingSystem)``
- Runtime: ``$($report.environment.runtime)``
- Coordinate coverage: $([math]::Round($report.dataQuality.coordinateCoverage * 100, 2))%
- Compressed bytes: $($report.dataQuality.compressedBytes)

| Metric | Samples | p50 (ms) | p95 (ms) |
|---|---:|---:|---:|
$($rows -join "`n")

**Status: PASSED**
"@
[System.IO.File]::WriteAllText($markdownPath, "$markdown`n", $utf8NoBom)
[System.IO.File]::WriteAllLines(
    $transcriptPath,
    [string[]]$transcript,
    $utf8NoBom
)

Write-Host "Saved $jsonPath"
Write-Host "Saved $markdownPath"
Write-Host "Saved $transcriptPath"
