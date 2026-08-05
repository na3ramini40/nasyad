---
name: nasyad-ux
description: >-
  Nasyad end-user UX — jobs, happy paths, en/fa copy, empty/error/confirm
  states, and tone. Use when designing or reviewing user-facing flows, strings,
  or interaction patterns in this app.
---

# Nasyad UX

Read [end-user.md](end-user.md) first — who, jobs, tone, learned patterns.

## Deliverables (Phase 1)

1. **User job** — one sentence, outcome-focused.
2. **Happy path** — ≤3 steps from entry to done.
3. **Copy plan** — en + fa keys or draft strings (hand off to l10n).
4. **States** — empty, loading, error, destructive confirm copy.
5. **Primary CTA** — one obvious action per screen.

## Gates

- Calm, short, concrete tone — action verbs.
- Status labels: Needs Service / Due Soon / Up to Date (devices); Due / Soon / Upcoming (home).
- No jargon, no fake cloud/sync promises.
- Destructive/import flows: state the consequence clearly.

## When to update `end-user.md`

Append durable facts only — not one-off task notes:

- New persona constraint or job
- Learned empty/error pattern that will repeat
- Model change (e.g. what Home means)

Do **not** duplicate screen lists — those live in `nasyad-product/app-map.md`.

## Align with product map

Before proposing new screens, read [app-map.md](../nasyad-product/app-map.md). If structure changes, flag for Phase 4 map update.

## Calendar & locale

Calendar preference ≠ language. See [calendar.md](../nasyad-flutter/calendar.md) for picker behavior.
