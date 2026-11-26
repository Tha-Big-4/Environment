# Design

Owned by the frontend; shared so the backend sees what the UI needs.

| Path | What |
|---|---|
| `DESIGN_RULES.md` | The rules every screen follows |
| `tokens.md` | Colour, type, spacing, radius, shadow tokens: the only allowed values |
| `stitch/` | Google Stitch exports: one folder per screen (`<screen>/screen.png`, `code.html`, `DESIGN.md`) |
| `references/` | Inspo references kept for a decision: screenshot + one line on what to take from it |

## Design workflow

1. **References** — Inspo MCP (`recommend`, `search_screens`) for 3-5 real sites; note what to take.
2. **Generate** — Google Stitch MCP / stitch-skills: generate the screen from a prompt, iterate.
3. **Export** — save the Stitch screen and its `DESIGN.md` into `stitch/<screen>/`.
4. **Tokens** — map Stitch colours and type onto `tokens.md`; add a token rather than hard-coding a value.
5. **Build** — implement with the project's components (BoardUI MCP for React + Tailwind projects).
6. **Check** — Playwright MCP screenshots at 375 / 768 / 1440 px, light and dark; Lighthouse accessibility ≥ 0.95.
