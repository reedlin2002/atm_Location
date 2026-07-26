param(
    [string]$FlutterExecutable = "flutter"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$factsPath = Join-Path $projectRoot "release\release-facts.json"
$facts = Get-Content -Raw -LiteralPath $factsPath | ConvertFrom-Json

$requiredEnvironment = @(
    "ATM_UPLOAD_KEYSTORE",
    "ATM_UPLOAD_KEY_ALIAS",
    "ATM_UPLOAD_STORE_PASSWORD",
    "ATM_UPLOAD_KEY_PASSWORD",
    "MAPS_API_KEY",
    "ATM_SUPPORT_EMAIL",
    "QUALITY_REPORT_PATH"
)
foreach ($name in $requiredEnvironment) {
    $value = [Environment]::GetEnvironmentVariable($name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        throw "Required release environment variable is missing: $name"
    }
}
if (-not (Test-Path -LiteralPath $env:ATM_UPLOAD_KEYSTORE -PathType Leaf)) {
    throw "ATM_UPLOAD_KEYSTORE does not identify a file"
}
if (-not (Test-Path -LiteralPath $env:QUALITY_REPORT_PATH -PathType Leaf)) {
    throw "QUALITY_REPORT_PATH does not identify a quality report"
}
if ($env:ATM_SUPPORT_EMAIL -eq "support@example.com") {
    throw "ATM_SUPPORT_EMAIL must be an owner-controlled address"
}

Push-Location $projectRoot
try {
    python -m pytest pipeline\tests -q
    if ($LASTEXITCODE -ne 0) { throw "Python tests failed" }

    Push-Location (Join-Path $projectRoot "app")
    try {
        & $FlutterExecutable pub get
        if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }
        & $FlutterExecutable gen-l10n
        if ($LASTEXITCODE -ne 0) { throw "flutter gen-l10n failed" }
        & $FlutterExecutable analyze
        if ($LASTEXITCODE -ne 0) { throw "flutter analyze failed" }
        & $FlutterExecutable test --concurrency=1 --exclude-tags production-performance
        if ($LASTEXITCODE -ne 0) { throw "Flutter tests failed" }
        & $FlutterExecutable test test\production_performance_gate_test.dart
        if ($LASTEXITCODE -ne 0) { throw "Performance gate failed" }

        $symbolsDirectory = Join-Path $projectRoot (
            "release-artifacts\{0}\symbols" -f $facts.versionName
        )
        New-Item -ItemType Directory -Force -Path $symbolsDirectory | Out-Null
        & $FlutterExecutable build appbundle --release `
            "--build-name=$($facts.versionName)" `
            "--build-number=$($facts.versionCode)" `
            --obfuscate `
            "--split-debug-info=$symbolsDirectory" `
            "--dart-define=ATM_SUPPORT_EMAIL=$($env:ATM_SUPPORT_EMAIL)"
        if ($LASTEXITCODE -ne 0) { throw "Release AAB build failed" }
    }
    finally {
        Pop-Location
    }

    $artifactDirectory = Join-Path $projectRoot (
        "release-artifacts\{0}" -f $facts.versionName
    )
    New-Item -ItemType Directory -Force -Path $artifactDirectory | Out-Null
    Copy-Item -LiteralPath (
        Join-Path $projectRoot "app\build\app\outputs\bundle\release\app-release.aab"
    ) -Destination $artifactDirectory
    Copy-Item -LiteralPath (
        Join-Path $projectRoot "app\build\app\outputs\mapping\release\mapping.txt"
    ) -Destination $artifactDirectory
    Copy-Item -LiteralPath $env:QUALITY_REPORT_PATH `
        -Destination (Join-Path $artifactDirectory "quality-report.json")
    Copy-Item -Path (Join-Path $projectRoot "performance\reports\*") `
        -Destination $artifactDirectory

    $checksums = Get-ChildItem -LiteralPath $artifactDirectory -File |
        Sort-Object Name |
        ForEach-Object {
            $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName
            "{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $_.Name
        }
    Set-Content -LiteralPath (
        Join-Path $artifactDirectory "SHA256SUMS"
    ) -Value $checksums
}
finally {
    Pop-Location
}
