[CmdletBinding()]
param(
    [string]$SourceDate = (Get-Date -Format 'yyyy-MM-dd'),
    [string]$DatasetVersion = "$((Get-Date -Format 'yyyy.MM.dd')).1",
    [string]$Python = 'python'
)

# 重新產生 App 內建的 ATM 資料（app/assets/catalog/baseline_catalog.json）。
#
# 1. 下載財金公司全國 ATM 清單（主資料）。
# 2. 疊加數位發展部、中華郵政座標與財金公司視障／輪椅無障礙清單。
# 3. 產生 catalog 與品質報告，再轉成 App 內建格式。
#
# 完成後要做的事：
# - 依印出的 total / withCoordinates 更新 app/test/bundled_catalog_test.dart。
# - 檢查 pipeline/build/baseline-<版本>/staged/quality-report-*.json。
# - 更新資料來源與授權頁的資料年份（app/lib/settings/data_sources.dart）。

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repository = Split-Path -Parent $PSScriptRoot
$pipeline = Join-Path $repository 'pipeline'
$work = Join-Path $pipeline "build/baseline-$DatasetVersion"
$sources = Join-Path $work 'sources'
$staged = Join-Path $work 'staged'
$baseline = Join-Path $repository 'app/assets/catalog/baseline_catalog.json'

if (Test-Path $staged) {
    throw "$staged 已存在；請換一個 -DatasetVersion，或先刪除舊的建置資料夾。"
}
New-Item -ItemType Directory -Force -Path $sources | Out-Null

$nationalList = Join-Path $sources 'A2_Location.csv'
Invoke-WebRequest -UseBasicParsing `
    -Uri 'https://www.fisc.com.tw/TC/OPENDATA/A2_Location.csv' `
    -OutFile $nationalList

$previousPythonPath = $env:PYTHONPATH
$env:PYTHONPATH = Join-Path $pipeline 'src'
try {
    & $Python -m atm_catalog_builder `
        --source $nationalList `
        --source-format fisc `
        --source-name fisc-national-atm `
        --source-date $SourceDate `
        --output $staged `
        --dataset-version $DatasetVersion `
        --published-at "$($SourceDate)T00:00:00Z" `
        --artifact-base-url "https://catalog.invalid/$DatasetVersion" `
        --official-overlays
    if ($LASTEXITCODE -ne 0) { throw "catalog 建置失敗（exit $LASTEXITCODE）" }

    $snapshot = Join-Path $staged "catalog-$DatasetVersion.ndjson.gz"
    & $Python -m atm_catalog_builder.baseline `
        --snapshot $snapshot `
        --dataset-version $DatasetVersion `
        --output $baseline
    if ($LASTEXITCODE -ne 0) { throw "內建資料轉換失敗（exit $LASTEXITCODE）" }
} finally {
    $env:PYTHONPATH = $previousPythonPath
}

Write-Host "已更新 $baseline（資料版本 $DatasetVersion）。"
Write-Host "品質報告：$(Join-Path $staged "quality-report-$DatasetVersion.json")"
