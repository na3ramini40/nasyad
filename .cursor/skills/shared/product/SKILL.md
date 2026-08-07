---
name: nasyad-product
description: >-
  What Nasyad users see and need — screen map, persona, jobs, en/fa copy, UX
  states, and tone. Use when scoping any user-facing feature, designing flows
  or strings, or updating product structure after UI ships.
---

# Product & UX

Two living documents — read before scoping, update in the same delivery that changes them:

- [app-map.md](app-map.md) — every screen: entry, shows, actions, leaves-to. **Wins** for UX chrome when screen descriptions disagree. Acceptance / capabilities → `docs/domain/structure.md`.
- [end-user.md](end-user.md) — persona, jobs, mental model, learned patterns.

## Scoping a feature (intake)

1. Restate the goal in one sentence against the current app-map.
2. Flag scope: client / server / both. Both → match `docs/domain.md` (open the shard), then API contract (`../api-contract/`).
3. Define done: PR only, or coupled release tag.

## UX deliverables (before building UI)

1. **Job** — one outcome-focused sentence.
2. **Happy path** — ≤3 steps from entry to done.
3. **Copy plan** — en + fa strings (become ARB keys).
4. **States** — empty, loading, error, destructive confirm.
5. One obvious primary action per screen.

## Tone gates

- Calm, short, concrete; action verbs; no jargon, no fake cloud/sync promises.
- Status labels: Needs Service / Due Soon / Up to Date (devices); Due / Soon / Upcoming (home).
- Destructive and import flows state the consequence explicitly.

## Updating the living docs

- **app-map.md** — when screens, sections, primary actions, navigation entries, or visible states change. One bullet per visible element, present tense, ≤8 bullets per block, no implementation detail. Skip for copy-only/refactor/backend work. Capability changes also update `docs/domain/structure.md`.
- **end-user.md** — durable facts only (new job, learned pattern, model change) — never one-off task notes, never screen lists.
