# Contributing to ATM Finder

Use a short-lived branch and a pull request into `main`. Before requesting
review, run:

```powershell
$env:PYTHONPATH = 'pipeline/src'
python -m pytest -q
Push-Location app
try {
  flutter analyze
  flutter test --concurrency=1 --exclude-tags production-performance
} finally {
  Pop-Location
}
```

Do not commit API keys, service accounts, upload keys, passwords, `.env`
files, `local.properties`, `google-services.json` from an unrelated Firebase
project, or generated release artifacts. If a credential is exposed, stop,
rotate it at the provider, and record only the non-secret incident outcome.

Issues remain in `.scratch/taiwan-atm-finder/issues/`. Do not create or migrate
GitHub Issues until `docs/agents/issue-tracker.md` has first been updated and
the project owner has approved the migration.

The required `main` ruleset and repository creation checklist are defined in
`.github/repository-governance.md`.
