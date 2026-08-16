# Enums (exact wire strings)

Where: **both** — every client and server must use these exact strings.

| Enum | Values |
|------|--------|
| `status` | `active`, `archived`, `deleted` |
| `schedule_type` | `calendarInterval`, `usageInterval`, `fixedDate` |
| `kind` (log) | `maintenanceDone`, `usageUpdate` |
| `calendar_system` | `gregorian`, `persian` |
| `category_preset` | `generic`, `car`, `hvac`, `appliance`, `electronics`, `plumbing` |
| calendar `interval_unit` | `days`, `weeks`, `months` |
| usage `usage_unit` / log unit | `km`, `hours`, `cycles` |
| place `kind` (local) | `point`, `line`, `polygon` |
| `lock_method` (local) | `password`, `pin`, `biometric` |
| `home_grouping` (local) | `device`, `tag` |

Index: [../domain.md](../domain.md)
