# Principles

Nasyad is a **local-first** maintenance tracker (devices/assets in a tree + personal birthdays). A conforming **client** works fully offline with a local store. A conforming **server** is optional remote sync/auth — never a divergent model.

## Where tags

Domain rules use **Where** so reimplementations know who must enact them:

| Tag | Meaning |
|-----|---------|
| **both** | Semantics every client and every server that touches the data must honor |
| **client** | Can only be enacted by a client; every client must produce this result |
| **server** | Can only be enacted by a server; every server must produce this result |

Same outcome across stacks: if two conforming implementations would answer a user-visible fact differently, one is wrong.

## Core rules

1. **Local-first** — Where: **client**. Local store is the UI source of truth; the product works without a server.
2. **Server optional** — Where: **both**. Sync/auth only for entities marked syncable; never invent fields or enums outside this tree.
3. **Same names, same wire values** — Where: **both**. Entity names, `snake_case` fields, and [enums.md](enums.md) strings are fixed.
4. **IDs** — Where: **both**. Syncable entity ids are opaque string UUIDs assigned by the client; servers upsert by that id (never renumber). Account profile `id` is a **server-issued** public hash ([user.md](user.md)) — exception to client-assigned ids.
5. **Timestamps** — Where: **both**. `created_at` / `updated_at` as ISO 8601 UTC; logs pull by `created_at`, others by `updated_at` — [sync.md](sync.md).
6. **Additive only** — Where: **both**. New fields optional + defaulted; ignore unknown fields.
7. **Computed ≠ stored** — Where: **both**. Due / soon / progress are derived, never persisted.
8. **Owner isolation** — Where: **server**. Synced rows scoped to `user_id`; clients have no `user_id` locally and must not trust another user’s rows.

Index: [../domain.md](../domain.md)
