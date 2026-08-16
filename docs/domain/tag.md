# Tag

Syncable. Named label for grouping devices on Home — **not** a Device. No usage, schedule, or maintenance of its own.

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | PK (client-assigned) |
| `name` | string | required, trimmed |
| `created_at` | datetime | |
| `updated_at` | datetime | conflict / pull cursor |

## DeviceTagLink

Syncable association. Composite identity `(device_id, tag_id)` per user.

| Field | Type | Notes |
|-------|------|-------|
| `device_id` | string | FK → Device id |
| `tag_id` | string | FK → Tag id |
| `created_at` | datetime | pull cursor for links |

## Rules

| Rule | Where |
|------|-------|
| Tags are labels only — never usage owners or schedule holders | both |
| Many devices ↔ many tags | both |
| Home tag mode rolls up worst status of tagged devices (via each device’s aggregate) | client |
| User never treats a tag as an asset device | client |
| Upserts keyed by client id (tags) or `(device_id, tag_id)` (links); user isolation | both |
| Deleting a tag removes its links for that user | both |

Related: [local.md](local.md) (Home grouping preference) · [sync.md](sync.md) · [structure.md](structure.md) · Index: [../domain.md](../domain.md)
