---
name: nasyad-product
description: >-
  Living map of what Nasyad users see — screens, sections, navigation, and
  primary actions. Use when planning features, scoping intake, or updating
  product structure after UI ships.
---

# Nasyad product map

**Source of truth:** [app-map.md](app-map.md) — screens and user-visible behavior only.

Complements [nasyad-ux/end-user.md](../nasyad-ux/end-user.md) (persona, jobs, tone).

## When to read

- Before scoping any user-facing change.
- Phase 0 (FDM intake): restate goal against current screens.
- Phase 1 (UX): align jobs/copy; propose map edits if structure changes.

## When to update (Phase 4)

Same delivery when adding, removing, or renaming:

- Screens or modals users open
- Sections, filters, primary actions
- Navigation entry points (tiles, FABs)
- Empty / loading / error states users see

**Skip** for copy-only, refactors, or backend-only work.

## Update rules

1. One bullet per visible element; no implementation detail.
2. ≤8 bullets per screen block; present tense.
3. Fix map before closing if unsure — read the shipped page once.
4. Report one line: what changed in the map.

## Screen template

```markdown
### Screen name
**Entry:** …
**Shows:** …
**Actions:** …
**Leaves to:** …
```

## Doc sync

If acceptance criteria change, sync [docs/app-description.md](../../../docs/app-description.md). **app-map wins** for UX when they disagree.
