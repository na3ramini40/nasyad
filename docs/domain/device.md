# Device

Syncable. Tree node (asset / part). Soft lifecycle; schedule optional.

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | PK |
| `parent_id` | string? | null = root |
| `name` | string | required |
| `description` | string? | |
| `category_preset` | enum? | [enums.md](enums.md) |
| `location_label` | string? | free text |
| `status` | enum | `active` \| `archived` \| `deleted` |
| `usage_unit` | enum? | if set → usage owner |
| `current_usage` | int | ≥ 0; shared on usage-owner |
| `schedule_type` | enum? | null = no schedule |
| `interval_value` | int? | with `interval_unit` |
| `interval_unit` | string? | calendar or usage unit — [enums.md](enums.md) |
| `fixed_due_at` | datetime? | when `schedule_type = fixedDate` |
| `last_maintained_at` | datetime? | |
| `usage_at_last_maintenance` | int | ≥ 0 |
| `created_at` | datetime | |
| `updated_at` | datetime | conflict / pull cursor |

## Rules

| Rule | Where |
|------|-------|
| Devices form a tree via nullable `parent_id` | both |
| At most one schedule per node; clearing schedule nulls all schedule fields together | both |
| Archive/delete cascades to the **whole subtree** | both |
| Usage reading lives on the nearest ancestor-or-self with `usage_unit` | both |
| Maintenance resets **that node’s** cycle only (`last_maintained_at` / `usage_at_last_maintenance`), not children | both |
| Aggregate due status / progress for roots is derived for list/home surfaces | client |

Related: [device-log.md](device-log.md) · [structure.md](structure.md) · Index: [../domain.md](../domain.md)
