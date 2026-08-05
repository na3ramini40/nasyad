---
name: nasyad-product
description: >-
  Living map of what Nasyad users see and interact with — screens, sections,
  navigation, and primary actions (not code). Use when planning or shipping
  features, answering "what does the app do?", or updating product structure.
  Feature Delivery Manager reads this before intake and updates it after UI ships.
---

# Nasyad product map

## Authority

**Source of truth:** [app-map.md](app-map.md)

- Describes **screens and user-visible behavior** only — not widgets, BLoC, or file paths.
- Complements `.cursor/skills/nasyad-ux/end-user.md` (who, jobs, tone) — do not duplicate tone/jobs there.

## When to read

- **Before** scoping or designing any user-facing change.
- **Phase 0 (FDM):** Read `app-map.md` to restate the goal against current product shape.
- **Phase 1 (UX):** Align jobs/copy with the map; propose map edits if the ask changes structure.

## When to update

Update `app-map.md` in the **same delivery** when the change adds, removes, or renames:

- A screen or modal users open
- A section, filter, or primary action on a screen
- Navigation entry points (menu tiles, FABs, deep links)
- Empty / loading / error states users see

**Do not update** for copy-only tweaks, refactors, or backend-only work — use `end-user.md` for durable UX facts instead.

### Update rules

1. One bullet per visible element; no implementation detail.
2. Keep each screen block ≤8 bullets.
3. Use present tense ("User sees…", "Tap opens…").
4. If unsure after shipping, read the page once and fix the map before closing the task.
5. Say in one line what changed in the map when reporting to the stakeholder.

## Screen block template

```markdown
### Screen name
**Entry:** how user gets here
**Shows:** …
**Actions:** …
**Leaves to:** …
```

## Related assets

| Asset | Owns |
|-------|------|
| `app-map.md` | Screens, sections, navigation, visible states |
| `nasyad-ux/end-user.md` | Persona, jobs, tone, learned empty/error patterns |
| `docs/app-description.md` | Acceptance criteria & feature list (engineering doc) |

When `app-map.md` and `docs/app-description.md` disagree after a ship, **app-map wins** for UX; sync `docs/app-description.md` if acceptance criteria changed.
