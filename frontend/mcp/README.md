# Frontend MCP servers

`../.mcp.json` is loaded when you start Claude Code in `frontend/`. Claude Code asks you to approve each
project server the first time. Keys come from environment variables (`${NAME}`), never from the file:
put them in `frontend/.env` and run `pwsh scripts/setup.ps1 -ApplyEnv`, then restart Claude Code.

| Server | For | Key |
|---|---|---|
| **stitch** | Google Stitch: generate UI screens from a prompt, iterate, export HTML and `DESIGN.md` | `STITCH_API_KEY` from stitch.withgoogle.com/settings |
| **inspo** | Real production sites: screenshots, palettes, fonts, layouts, as design references | none |
| **boardui** | React + Tailwind v4 design system; installs components into the project | none (Pro: activate a license from inside the server) |
| **playwright** | Drive a real browser: screenshots at each breakpoint, visual checks, e2e debugging | none |
| **context7** | Current docs for whatever framework or library the project uses | none (sign in on first use) |
| **github** | Issues, PRs, code search | `GITHUB_TOKEN` (fine-grained PAT, optional) |

## Skills that go with them

- **stitch-skills** (Google Labs): `pwsh scripts/setup.ps1 -Install` runs
  `npx plugins add google-labs-code/stitch-skills --scope project --target claude-code`.
  It is a Google Labs project and "not an officially supported Google product".
- **design-workflow** (`.claude/skills/design-workflow/`): Inspo → Stitch → tokens → build → Playwright check.
- **frontend-design** (Claude plugin, optional): `/plugin install frontend-design@claude-plugins-official`.

## Optional servers

`optional/` holds ready entries for stack-specific servers (Angular CLI, Figma, Chrome DevTools).
Copy the entry into `../.mcp.json` when the project needs it.

## Adding a server

1. Add it to `../.mcp.json` (keys as `${NAME:-}`).
2. Add the key to `../.env.example` and `EnvKeys` in `../environment.psd1`.
3. Add a row to the table above.
