# Deliver feature

Canonical Nasyad delivery pipeline. FDM runs this end-to-end unless phases are clearly skippable.

## Output at start

```markdown
## Goal
<one sentence — what ships for the end user>

## Skill breakdown
| Task | Owner | Done when |
|------|-------|-----------|
| … | nasyad-ux | … |
| … | nasyad-flutter | … |
| … | nasyad-ui | … |
| … | ci-before-pr | `./tool/ci_verify.sh` exit 0 |
| … | git-delivery | committed (+ pushed / PR if requested) |
| … | github-tag-release | (only if release) |

## Sequence
0 → 1 → 2 → 3 → 4 → 5 → 6 → (7 if release)
```

Update the table as phases complete.

## Phases

**0 Intake** — Read `skills/nasyad-product/app-map.md`. Restate goal, scope, done criteria (PR vs tag). Check git branch. Decide semver per `rules/github-tag-release.mdc` unless user overrides. Route new policies via `skills/fdm-meta/SKILL.md`.

**1 UX** — Read `skills/nasyad-ux/SKILL.md` + `end-user.md`. Job, ≤3-step path, en/fa copy, empty/error/confirm. Gate: one primary action; no jargon; no fake cloud/sync.

**2 Architecture** — Read `skills/nasyad-flutter/SKILL.md` + relevant shards + `docs/`. Layers, Drift, BLoC, codegen. Gate: active stack; folders match `docs/AGENTS.md`.

**3 UI** — Read `skills/nasyad-ui/SKILL.md`. Bottom-up components; l10n strings; thin pages. Gate: theme-aligned; no monolithic pages.

**4 Integrate** — Wire UX + architecture + UI. Smallest surface. Update `app-map.md` if user-visible structure changed. Sync `docs/app-description.md` if acceptance criteria changed (app-map wins for UX).

**5 CI** — Run `/verify-ci`. Hard stop before PR, push-for-PR, or “PR ready” claims.

**6 Git** — Run `/ship-pr` when user wants ship/save. Commit only on explicit ship intent or this command.

**7 Release** — Run `/bump-release` + tag per `rules/github-tag-release.mdc` when goal includes release.

## Skip rules

- Copy-only: 1 → 4 → 5 (skip 2–3 if no code structure change).
- Refactor-only: 2 → 4 → 5.
- Never skip Phase 5 before GitHub PR/MR or tagging.

## Parallelism

- l10n copy can start before widgets exist.
- Domain/data once UX jobs are clear.
- UI after enough contracts — not every edge polished.
- Never parallelize past CI into PR/push-for-PR/tag.
