# Place

Syncable. Named map geometry for offline reference (point / line / polygon).

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | PK (client-assigned) |
| `name` | string | required, trimmed |
| `kind` | enum | `point` \| `line` \| `polygon` — [enums.md](enums.md) |
| `points` | `{lat, lng}[]` | wire JSON array; length ≥ kind min points |
| `notes` | string? | |
| `created_at` | datetime | |
| `updated_at` | datetime | conflict / pull cursor |

## Rules

| Rule | Where |
|------|-------|
| Upserts keyed by client `id`; user isolation | both |
| Pull cursor by `updated_at` | both |
| Conflict default: local wins (same as devices/birthdays) | both |
| Geometry must satisfy kind min point counts | both |

Related: [local.md](local.md) (map UI) · [sync.md](sync.md) · Index: [../domain.md](../domain.md)
