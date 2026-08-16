# Sync

Optional remote replication of syncable entities ([device.md](device.md), [device-log.md](device-log.md), [birthday.md](birthday.md), [tag.md](tag.md)). Local-first semantics in [principles.md](principles.md) still win.

## Rules

| Rule | Where |
|------|-------|
| Conflict default: **local wins** when the same entity id exists on both sides with meaningfully different data | both |
| Before any merge that would **override** the other side, the client must warn the user and get **explicit confirmation** — no silent overwrite of local or remote | client |
| On confirm: keep local rows for conflicting ids; push local to the server (override remote); never apply conflicting remote rows onto Drift | client |
| On cancel / dismiss: abort the sync write path — leave local and remote as-is for conflicting ids; do not push overrides; do not pull overwrites; local data must not be lost | client |
| Non-conflicting additive sync is allowed without confirmation: local-only creates on push; remote-only inserts on pull; identical ids are no-ops | client |
| Device logs stay append-only by id (insert remote only when missing locally); same-id log rows are not overwritten either way | both |
| Pull cursors: devices/birthdays/tags by `updated_at`; logs by `created_at`; device–tag links by `created_at` | both |
| Upserts keyed by client-assigned entity `id` (idempotent); device–tag links by `(device_id, tag_id)` | both |
| Creating a device log on the server applies the same usage / maintenance side effects as the client ([device-log.md](device-log.md)) and bumps affected devices’ `updated_at` | server |
| Server enforces `user_id` + row-level isolation; after a confirmed local-wins push the client may advance `updated_at` so the server store accepts the owner’s chosen row | both |
| Client never trusts another user’s rows; sync fills the local store, never replaces local-first reads | client |
| Auth secrets live in env / host secrets only — never in the domain model or repo | server |
| Account auth is phone OTP + DRF token; profile shape in [user.md](user.md) | both |

Wire checklist: `.cursor/skills/shared/api-contract/`. Index: [../domain.md](../domain.md)
