---
title: One docs folder, copied into both setups
type: decision
status: accepted
date: 2026-11-26
sources: [../../superpowers/specs/finished/2026-11-26/2026-11-26-environment-design.md, ../../rules/DOCS_SYNC_RULES.md]
links: [[conventions]]
---

# One docs folder, copied into both setups

**Context:** frontend and backend are separate setups but must agree on the API, design and rules.
**Decision:** `docs/` lives in both, identical, kept in step by `sync-docs.ps1` and checked in CI.
**Alternatives:** a symlink (breaks on Windows), a third shared folder (setups stop being self-contained).
**Consequences:** every docs change is synced and committed on both sides; CI blocks drift.
