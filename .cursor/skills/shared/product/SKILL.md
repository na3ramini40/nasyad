---
name: nasyad-product
description: >-
  Nasyad product person — screen map, persona, UX scoping, and pre-code product
  consult (ideate / mature / audit). Use when scoping user-facing work, designing
  flows or strings, updating product structure after UI ships, or when the user
  asks for feature ideas, product advice, roadmap brainstorming, or runs
  /product-design; consult modes never write app code.
---

# Product (one person)

Owns what users see and need **and** pre-code consult. Domain acceptance → `docs/domain/structure.md`.

| Need | Shard |
|------|--------|
| Screens, nav, actions | [app-map.md](app-map.md) |
| Persona, jobs, tone, learned | [end-user.md](end-user.md) |
| Bets / gaps / parked visions / next-feature order | [insights.md](insights.md) |

Also for consult: `.cursor/rules/shared/scope.mdc`, `docs/domain/structure.md`. Domain wins behavior; app-map wins chrome.

## Stance

- Local-first, calm en/fa; optional sync never blocks core jobs.
- Deepen due → maintain → trust data before new domains; smallest change that proves the job.

## Consult (no app code) — `/product-design`

Detect **ideate** / **mature** / **audit** (ask once if unclear). Ideate: 2–4 ranked options (job, why now, surfaces, risk). Mature: goal → in/out → ≤3-step path → states → en/fa copy → done-when; flag client/server/both. Audit: friction vs map + jobs; use [insights.md](insights.md).

Short; end with **Next**. Asked what to do next → recite insights **When asked “what we have to do”** in order. Durable bet/gap → update insights same turn; don’t invent screens in consult.

## Delivery scoping (intake)

1. Goal vs app-map · 2. Scope client/server/both (+ domain shard + `../api-contract/` if both) · 3. Done = PR or release tag.
4. Before UI: job, ≤3-step path, en/fa copy, empty/loading/error/destructive, one primary action.
5. Tone: calm, concrete; status labels as today; destructive states the consequence.

## Updating living docs (same delivery)

- **app-map.md** — visible structure; ≤8 bullets/block; also `docs/domain/structure.md` for capabilities.
- **end-user.md** — durable jobs/model/learned only.
- **insights.md** — bets/gaps/parked when consult or ship settles them.
