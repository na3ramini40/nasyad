# FDM roster (authoritative)

FDM reads this first; scan disk to fix drift. Update when adding skills, rules, or commands.

## Skills

| Asset | Path | Phases | Owns |
|-------|------|--------|------|
| nasyad-product | `.cursor/skills/nasyad-product/` | 0, 4 | Screens, nav, visible states (`app-map.md`) |
| nasyad-ux | `.cursor/skills/nasyad-ux/` | 1 | Jobs, copy, tone, empty/error (`end-user.md`) |
| nasyad-flutter | `.cursor/skills/nasyad-flutter/` | 2 | Architecture, Drift, BLoC, l10n, calendar, transfer |
| nasyad-ui | `.cursor/skills/nasyad-ui/` | 3 | Component UI, theme, a11y |
| crecreate | `.cursor/skills/crecreate/` | — | Scenario → Flutter test implementation |
| fdm-meta | `.cursor/skills/fdm-meta/` | — | Policy routing, asset maintenance |

## Rules

| Asset | Path | Phases | Owns |
|-------|------|--------|------|
| ci-before-pr | `.cursor/rules/ci-before-pr.mdc` | 5 | Local Verify before PR/MR |
| pub-mirror | `.cursor/rules/pub-mirror.mdc` | 2, 5 | Runflare pub/Flutter mirror |
| android-release-signing | `.cursor/rules/android-release-signing.mdc` | 7 | Release keystore access |
| github-tag-release | `.cursor/rules/github-tag-release.mdc` | 7 | Semver, changelog, tag flow |
| git-delivery | `.cursor/rules/git-delivery.mdc` | 6 | Commit, push, PR safety |
| nasyad-scope | `.cursor/rules/nasyad-scope.mdc` | all | Product/engineering boundaries |

## Commands

| Asset | Path | Phases | Owns |
|-------|------|--------|------|
| deliver-feature | `.cursor/commands/deliver-feature.md` | all | Full pipeline |
| verify-ci | `.cursor/commands/verify-ci.md` | 5 | `./tool/ci_verify.sh` |
| ship-pr | `.cursor/commands/ship-pr.md` | 6 | Commit, push, `gh pr` |
| bump-release | `.cursor/commands/bump-release.md` | 7 | Version + changelog |
| save-progress | `.cursor/commands/save-progress.md` | — | `docs/ailogs.md` line |
| crecreate | `.cursor/commands/crecreate.md` | — | Scenario → test implementation |

## Agent

| Asset | Path | Owns |
|-------|------|------|
| feature-delivery-manager | `.cursor/agents/feature-delivery-manager.md` | Orchestration entry |
