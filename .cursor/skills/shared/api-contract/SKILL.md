---
name: nasyad-api-contract
description: >-
  Client↔server API and sync contracts. Use when a feature changes both
  client/ and server/, or when defining payloads, auth, or sync cursors.
---

# API contract

Entity shapes and correctness: [`docs/domain.md`](../../../../docs/domain.md) + [`docs/domain/`](../../../../docs/domain/) (bible). This skill covers **how** those entities cross the wire — never redefine them here.

Cross-stack features need an explicit contract **before** parallel implementation. Confirm fields against the matching domain shard; both sides implement against it; ship in one PR when user-visible (coupled release — shared release rule).

## Contract checklist

| Item | Client | Server |
|------|--------|--------|
| Resource | entity from `docs/domain/` | Django app + model matching that shard |
| JSON fields | snake_case in `client/lib/data/` adapters | serializer fields — same names/enums as [enums.md](../../../../docs/domain/enums.md) |
| IDs | string UUIDs (client-assigned) | same in DB — idempotent upserts keyed by client id |
| Timestamps | ISO 8601 UTC | `DateTimeField` |
| Auth | token header via repository port | DRF permission class; `user_id` FK + row-level isolation on synced models |
| Pull cursor | SyncStateStore key | per [sync.md](../../../../docs/domain/sync.md) |
| Breaking change | Drift migration + fallback | migration + coordinated release + domain shard update |

## Principles

- Client Drift stays the UI source of truth — sync fills it, never replaces local-first reads.
- Additive fields over versioned breaks; both sides tolerate unknown fields.
- Conflict policy per [sync.md](../../../../docs/domain/sync.md) (default: **local wins** with explicit user confirmation before any override).

