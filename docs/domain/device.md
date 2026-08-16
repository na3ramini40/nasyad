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
| `usage_unit` | enum? | if set → usage owner for this node |
| `current_usage` | int | ≥ 0; absolute reading on the usage owner (default `0`) |
| `schedule_type` | enum? | null = no schedule |
| `interval_value` | int? | with `interval_unit` |
| `interval_unit` | string? | calendar or usage unit — [enums.md](enums.md) |
| `fixed_due_at` | datetime? | when `schedule_type = fixedDate` |
| `last_maintained_at` | datetime? | last **confirmed** maintenance (not last usage log) |
| `usage_at_last_maintenance` | int | ≥ 0; usage baseline at last confirmed maintenance |
| `created_at` | datetime | |
| `updated_at` | datetime | conflict / pull cursor |

## Rules

| Rule | Where |
|------|-------|
| Devices form a tree via nullable `parent_id` | both |
| At most one schedule per node; clearing schedule nulls all schedule fields together | both |
| Archive/delete cascades to the **whole subtree** | both |
| Usage reading lives on the nearest ancestor-or-self with `usage_unit` (**inherit by default**). A child opts out by setting its **own** `usage_unit` | both |
| Child schedule baselines (`usage_at_last_maintenance` / initial elapsed) never write the parent’s `current_usage` | both |
| Maintenance resets **that node’s** cycle only (`last_maintained_at` / `usage_at_last_maintenance`), not children | both |
| Due / soon / progress / remaining / target are **computed** from schedule + last maintenance + current usage — never stored | both |
| No schedule on a node → that node has no own next/progress/due; UI may hint to add a schedule | client |
| Aggregate status for a node = **worst of** (own schedule if any, each child’s aggregate). Progress = max of those | client |
| Usage-interval “next” surfaces show **remaining** and **target** absolute reading (`usage_at_last_maintenance + interval`) | client |
| Soon threshold for devices is the same progress fraction for calendar and usage schedules (0.8) | client |

Related: [device-log.md](device-log.md) · [structure.md](structure.md) · [local.md](local.md) (tags) · Index: [../domain.md](../domain.md)
