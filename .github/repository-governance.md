# ATM Finder repository governance

This document is the repository-side contract for the dedicated GitHub
repository. The current remote owner and CODEOWNER are `reedlin2002`;
repository visibility still requires owner confirmation before public release.

## Repository shape

- Visibility: public.
- Default branch: `main`.
- Releases and immutable catalog assets are published through GitHub HTTPS.
- GitHub Actions is enabled; workflow permissions default to read-only and are
  elevated only in the individual publishing job that requires them.
- Local Markdown under `.scratch/` remains the issue tracker until
  `docs/agents/issue-tracker.md` is explicitly changed first.

## Required `main` ruleset

Apply one branch ruleset to `main`:

1. Require a pull request before merging.
2. Require at least one approval from the confirmed project owner.
3. Dismiss stale approvals after new commits.
4. Require all conversations to be resolved.
5. Require these status checks:
   - `pipeline`
   - `flutter`
   - `production-performance`
6. Block force pushes and branch deletion.
7. Apply the ruleset to administrators; emergency bypass is restricted to the
   confirmed owner and must leave an audit-log reason.

Direct commits to `main` are not part of the normal release flow.

## Secrets and environments

- Google, Firebase, TGOS and Android upload credentials never enter source,
  issues, workflow logs, catalog artifacts or release attachments.
- Local credentials use ignored files or process environment variables.
- GitHub credentials use environment-scoped Actions secrets.
- The release environment requires owner approval before accessing upload
  signing material.
- Any credential found in plaintext is revoked or rotated before the next
  build; deleting the file is not sufficient.

## Initial repository checklist

- [x] Confirm and record the GitHub owner (`reedlin2002`).
- [ ] Create the public repository and set `main` as default.
- [ ] Add the local repository as `origin` only after verifying its exact URL.
- [ ] Enable Actions and Releases.
- [ ] Apply the `main` ruleset above.
- [ ] Configure the protected release environment and secrets.
- [ ] Run CI from a pull request and verify the three required checks.
- [ ] Publish a harmless test release artifact over public HTTPS, then remove
      that test release before the production candidate.
