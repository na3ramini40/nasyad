# Nasyad agent entry

Start here for AI-assisted work on this repo.

## Authority

1. [`docs/AGENTS.md`](../docs/AGENTS.md) — engineering layout and stack
2. [`.cursor/rules/`](rules/) — hard gates (CI, git, scope, release)
3. [`.cursor/skills/`](skills/) — product, UX, Flutter, UI craft
4. [`.cursor/agents/feature-delivery-manager.md`](agents/feature-delivery-manager.md) — delivery orchestrator

## Feature delivery

Use **Feature Delivery Manager** when shipping user-facing work, opening a PR, or managing a release:

- Agent: [`.cursor/agents/feature-delivery-manager.md`](agents/feature-delivery-manager.md)
- Pipeline: [`.cursor/commands/deliver-feature.md`](commands/deliver-feature.md)
- Asset index: [`.cursor/skills/fdm-roster/roster.md`](skills/fdm-roster/roster.md)

## Slash commands

| Command | Purpose |
|---------|---------|
| `/deliver-feature` | Full delivery pipeline (Phases 0–7) |
| `/verify-ci` | Run `./tool/ci_verify.sh` |
| `/ship-pr` | Commit, push, open PR (after green CI) |
| `/bump-release` | Semver bump + en/fa changelog |
| `/save-progress` | Append one line to `docs/ailogs.md` |
| `/crecreate` | Implement tests from a described scenario |

## Product vs engineering

| Side | Skills |
|------|--------|
| Product | `nasyad-product`, `nasyad-ux` |
| Software | `nasyad-flutter`, `nasyad-ui` |
| Meta | `fdm-meta`, `fdm-roster` |

Living data: `app-map.md`, `end-user.md` — update in the same delivery when structure or durable UX facts change.
