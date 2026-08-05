---
name: nasyad-ui
description: >-
  Nasyad Flutter UI composition — Atomic Design, design system, theme-aligned
  widgets, and accessibility. Use when building or refactoring screens,
  components, or design-system widgets in this repo.
---

# Nasyad UI

Owns **how UI is composed** — not domain/data. Stack authority: [nasyad-flutter](../nasyad-flutter/SKILL.md) + `docs/AGENTS.md`.

## Reference

Component rules and Atomic mapping: [components.md](components.md)

## Workflow

1. Identify Atomic level (atom → page).
2. Search `lib/core/ui/` and feature folders for reuse.
3. Build bottom-up; keep pages thin (layout + bloc wiring).
4. Strings from l10n — see [l10n.md](../nasyad-flutter/l10n.md).
5. Explicit loading / empty / error UI.
6. a11y: semantics, contrast, tap targets, text scaling.

## Placement

| Level | Location |
|-------|----------|
| Atoms / molecules (shared) | `lib/core/ui/` |
| Feature-only UI | `lib/presentation/<feature>/` |
| Pages | `lib/presentation/<feature>/pages/` |
| Theme tokens | `lib/core/theme/` |

Extract to `core/ui` when reused by 2+ features; sync `docs/AGENTS.md` if layout docs change.

## Gates

- No monolithic page files reimplementing buttons/rows inline.
- No hard-coded colors/typography bypassing `Theme`.
- No domain types in leaf atoms — pass presentational values.

## Output

Small typed widgets, clear APIs, brief note when extracting a new shared component.
