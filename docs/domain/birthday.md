# Birthday

Syncable.

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | PK |
| `name` | string | required |
| `birth_month` | int | 1–12 (calendar of `calendar_system`) |
| `birth_day` | int | valid day in that month/system |
| `calendar_system` | enum | `gregorian` \| `persian` |
| `created_at` | datetime | |
| `updated_at` | datetime | pull cursor |

## Rules

| Rule | Where |
|------|-------|
| No birth year stored or required | both |
| Calendar system is per row (independent of UI language) | both |
| Feeds the home reminders queue as upcoming personal follow-ups | client |

Index: [../domain.md](../domain.md)
