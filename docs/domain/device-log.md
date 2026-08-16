# DeviceLog

Syncable. Append-only history on a [Device](device.md). Photos: local path on device; transit may carry `photo_base64` (not a persisted store column).

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | PK |
| `device_id` | string | FK → Device |
| `date` | datetime | event date |
| `notes` | string? | |
| `kind` | enum | `maintenanceDone` \| `usageUpdate` |
| `usage_value` | int? | absolute reading; required for `usageUpdate`; required for `maintenanceDone` when a usage owner exists |
| `usage_unit` | enum? | [enums.md](enums.md) |
| `cost` | number? | |
| `cost_currency` | string? | |
| `vendor` | string? | |
| `photo_path` | string? | local only; sync policy TBD |
| `created_at` | datetime | pull cursor |

## Rules

| Rule | Where |
|------|-------|
| `usageUpdate` sets absolute usage on the usage owner; does **not** reset maintenance baselines | both |
| Absolute usage must not decrease below the usage owner’s current reading | both |
| Crossing an interval only changes computed due/soon — it never auto-creates maintenance | both |
| `maintenanceDone` resets **that** device’s maintenance cycle only | both |
| When a usage owner exists, `maintenanceDone` **also** records `usage_value` on the owner (same absolute-reading rules), then sets `usage_at_last_maintenance` to that reading | both |
| When no usage owner exists, `maintenanceDone` only sets `last_maintained_at` (calendar / fixed schedules) | both |
| Logs are append-oriented history for a device (edit/delete policy must not silently rewrite history without a domain update) | both |
| Photo bytes may travel in export/sync transit as `photo_base64`; durable local attachment is `photo_path` | client |

Index: [../domain.md](../domain.md)
