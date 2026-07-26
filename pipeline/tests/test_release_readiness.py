from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).parents[2]
GOOGLE_API_KEY_PATTERN = re.compile(r"AIza[0-9A-Za-z_-]{20,}")


def test_android_release_configuration_is_signed_only_by_injected_upload_key() -> None:
    gradle = (ROOT / "app/android/app/build.gradle.kts").read_text(encoding="utf-8")
    manifest = (ROOT / "app/android/app/src/main/AndroidManifest.xml").read_text(
        encoding="utf-8"
    )

    assert "minSdk = 24" in gradle
    assert "targetSdk = 36" in gradle
    assert "isMinifyEnabled = true" in gradle
    assert "isShrinkResources = true" in gradle
    assert 'signingConfigs.getByName("debug")' not in gradle
    assert "ATM_UPLOAD_KEYSTORE" in gradle
    assert "ATM_UPLOAD_STORE_PASSWORD" in gradle
    assert "${MAPS_API_KEY}" in manifest
    assert GOOGLE_API_KEY_PATTERN.search(manifest) is None
    assert "firebase" not in manifest.lower()
    ios_info = (ROOT / "app/ios/Runner/Info.plist").read_text(encoding="utf-8")
    assert "firebase" not in ios_info.lower()
    pubspec = (ROOT / "app/pubspec.yaml").read_text(encoding="utf-8")
    assert "firebase_" not in pubspec
    settings_page = (ROOT / "app/lib/settings/settings_page.dart").read_text(
        encoding="utf-8"
    )
    assert "DiagnosticsConsentTile" not in settings_page
    assert not (ROOT / "app/lib/diagnostics/crash_diagnostics.dart").exists()


def test_release_source_does_not_embed_google_api_keys() -> None:
    source_roots = (
        ROOT / "app/lib",
        ROOT / "app/android/app/src",
        ROOT / "app/ios/Runner",
        ROOT / "app/web",
        ROOT / "scripts",
        ROOT / "release",
        ROOT / ".github",
        ROOT / "pipeline",
    )
    text_suffixes = {
        ".dart",
        ".gradle",
        ".html",
        ".java",
        ".js",
        ".json",
        ".kt",
        ".kts",
        ".md",
        ".plist",
        ".properties",
        ".ps1",
        ".py",
        ".swift",
        ".xml",
        ".yaml",
        ".yml",
    }

    embedded_key_files = []
    for source_root in source_roots:
        for path in source_root.rglob("*"):
            if path.is_file() and path.suffix.lower() in text_suffixes:
                content = path.read_text(encoding="utf-8")
                if GOOGLE_API_KEY_PATTERN.search(content) is not None:
                    embedded_key_files.append(str(path.relative_to(ROOT)))

    assert embedded_key_files == []


def test_release_facts_and_owner_documents_are_complete_and_consistent() -> None:
    facts = json.loads(
        (ROOT / "release/release-facts.json").read_text(encoding="utf-8")
    )
    assert facts["applicationId"] == "com.reedlin2002.atmfinder"
    assert facts["versionName"] == "1.0.0"
    assert facts["versionCode"] == 1
    assert facts["minSdk"] == 24
    assert facts["targetSdk"] == 36
    assert facts["accountRequired"] is False
    assert facts["advertising"] is False
    assert facts["backgroundLocation"] is False
    assert facts["crashDiagnosticsIncluded"] is False
    assert facts["appOwnedRemoteCollection"] is False
    assert facts["mapsSdkDataCollection"] is True
    assert facts["mapsSdkDisclosureReviewRequired"] is True
    assert facts["supportEmail"] == "lin1022business@gmail.com"

    required_documents = (
        "privacy-policy-zh-TW.md",
        "play-data-safety-zh-TW.md",
        "financial-features-zh-TW.md",
        "store-listing-zh-TW.md",
        "release-checklist.md",
    )
    for name in required_documents:
        content = (ROOT / "release" / name).read_text(encoding="utf-8")
        assert len(content) >= 400, name
        assert "{{SUPPORT_EMAIL}}" not in content
        assert "lin1022business@gmail.com" in content or name == "release-checklist.md"


def test_release_workflow_packages_aab_mapping_checksums_and_reports() -> None:
    workflow = (ROOT / ".github/workflows/release-candidate.yml").read_text(
        encoding="utf-8"
    )
    for required in (
        "app-release.aab",
        "mapping.txt",
        "SHA256SUMS",
        "performance/reports",
        "android_performance_report_url",
        "android-performance-report.json",
        "quality-report",
        "flutter analyze",
        "pytest",
        "release/release-facts.json",
    ):
        assert required in workflow
    assert "--build-name=1.0.0" not in workflow


def test_local_release_command_requires_android_gate_and_reproducible_python_path() -> (
    None
):
    script = (ROOT / "scripts/build-release.ps1").read_text(encoding="utf-8")

    assert '"ANDROID_PERFORMANCE_REPORT_PATH"' in script
    assert "environment.operatingSystem" in script
    assert 'status -ne "passed"' in script
    assert '"pipeline\\src"' in script
    assert "Copy-Item -LiteralPath $env:ANDROID_PERFORMANCE_REPORT_PATH" in script
    assert '"performance\\reports\\*"' in script


def test_android_minimum_tier_workflow_is_rerunnable_without_provider_keys() -> None:
    workflow = (ROOT / ".github/workflows/android-minimum-tier.yml").read_text(
        encoding="utf-8"
    )

    for required in (
        "workflow_dispatch",
        "api-level: 29",
        "target: google_apis",
        "arch: x86_64",
        "cores: 2",
        "ram-size: 2048M",
        "run-android10-performance.ps1",
        "production-like-2026.07.26-android-api29-2gb",
    ):
        assert required in workflow
    assert "MAPS_API_KEY" not in workflow
    assert "FIREBASE" not in workflow
