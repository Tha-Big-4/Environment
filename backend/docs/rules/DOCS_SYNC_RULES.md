# Docs sync rules

`frontend/docs/` and `backend/docs/` are **the same folder in two places**. Each setup is
self-contained, so each carries the docs, and the docs are how the two sides talk to each other.

## Rules

1. **Edit one side, sync, commit both.** After changing docs in one setup, run from that setup:

   ```powershell
   pwsh scripts/sync-docs.ps1          # copies this side's docs/ over the other side's
   ```

   Commit both copies in the same commit.
2. **Check before you push.** `pwsh scripts/sync-docs.ps1 -Check` exits `1` and lists every file that
   differs. The pre-commit hook and CI run it; a commit with out-of-sync docs is blocked.
3. **Pull before you edit.** If the other side changed docs since your last sync, sync from that side
   first (`pwsh ../backend/scripts/sync-docs.ps1` or `../frontend/...`), then make your change.
4. **Mirror, not merge.** Sync makes the target identical to the source, deleting files the source no
   longer has. If both sides changed, resolve by hand first.
5. **The API contract is owned by the backend** (`docs/api/`), the design system by the frontend
   (`docs/design/`). Either side may edit any doc, but the owner reviews changes to its folder.

## Why a copy and not a symlink

Symlinks break on Windows checkouts without developer mode and in some zip downloads. A copy plus a
check works everywhere.
