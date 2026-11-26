---
name: design-workflow
description: Use when designing or redesigning a screen, page or component in the frontend project — before writing UI code — and when checking a built UI against its design.
---

# Design workflow

Uses the frontend MCP servers (`.mcp.json`): **inspo**, **stitch**, **boardui**, **playwright**.
Rules: `docs/design/DESIGN_RULES.md`. Tokens: `docs/design/tokens.md`.

1. **Brief.** One paragraph: who uses the screen, the one primary action, the data it shows.
2. **References.** Inspo `recommend` with the brief, one or two `search_screens`, `get_screen` on the
   3-5 you keep. Save each as `docs/design/references/YYYY-MM-DD-<site>-<what>.md` with what to take.
3. **Generate.** Stitch MCP with the `stitch-enhance-prompt` and `stitch-generate-design` skills:
   generate the screen from the brief and the tokens; iterate until the user approves it. Desktop and
   mobile variants. `stitch-manage-design-system` keeps the Stitch design system in line with `tokens.md`.
4. **Export.** Save into `docs/design/stitch/<screen>/`: `screen.png`, `code.html`, and `DESIGN.md`
   (`stitch-extract-design-md` / `stitch-design-md`).
5. **Tokens.** Map every colour, size and spacing in the export onto `tokens.md`. New value → new token.
6. **Build.** Implement with the project's own component library. For React + Tailwind projects,
   BoardUI MCP (`list_components`, `get_component`, `install_components`). Never paste Stitch HTML
   wholesale into the app; rebuild it from components and tokens.
7. **Check.** Playwright MCP screenshots at 375, 768 and 1440 px in light and dark; compare with the
   export; keyboard-walk the screen. Then `pwsh scripts/perf-bench.ps1` (accessibility ≥ 0.95).
8. **Docs.** `pwsh scripts/sync-docs.ps1` so the backend sees the design.

If the project already has a design system, it wins over Inspo and Stitch suggestions.
