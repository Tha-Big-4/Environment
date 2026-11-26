---
title: Prism 5 mock exits at start (isPrimary)
folder: 04-gotchas
type: gotcha
status: done
updated: 2026-11-26
sources: [../../../docker/compose.yml]
links: [[2026-W48]]
---

# Prism 5 mock exits at start

**Symptom:** `api-mock` container exits with code 1 right after start; logs show
`TypeError: Cannot read properties of undefined (reading 'isPrimary')` in `createMultiProcessPrism`.
**Cause:** Prism 5's multi-process mode reads a Node cluster API that is not there in its image.
**Fix:** start it single-process: `mock --multiprocess=false ...` (already set in `frontend/docker/compose.yml`).
