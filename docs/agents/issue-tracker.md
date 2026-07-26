# Issue tracker: Local Markdown

Issues and PRDs for this project live as Markdown files in `.scratch/`.

The parent workspace Git remote points to an unrelated personal website repository. Do not publish ATM Finder issues or PRDs to that remote.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The PRD is `.scratch/<feature-slug>/PRD.md`
- Implementation issues are `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`
- Triage state is recorded as a `Status:` line near the top of each file
- Comments and conversation history append under a `## Comments` heading

## Publishing

When a skill says to publish to the issue tracker, create or update the appropriate Markdown file under `.scratch/<feature-slug>/`.

When a skill says to fetch a ticket, read the referenced file or issue number from that directory.

If this project later receives its own dedicated GitHub repository, update this document before publishing issues externally.
