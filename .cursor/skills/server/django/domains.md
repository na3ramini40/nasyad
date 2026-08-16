# Server domains

**Bible:** [`docs/domain.md`](../../../../docs/domain.md) → [`docs/domain/`](../../../../docs/domain/) (structure + Where-tagged rules). Outcomes must match any stack.
Client paths: `.cursor/skills/client/flutter/domains.md`. Synced models: `user` FK + row-level isolation.

| Domain | App / prefix | Shard |
|--------|--------------|-------|
| **devices** | `server/devices/` → `/api/devices/` (+ `/api/devices/logs/`, `/tags/`, `/tag-links/`) | [device.md](../../../../docs/domain/device.md), [device-log.md](../../../../docs/domain/device-log.md), [tag.md](../../../../docs/domain/tag.md); [sync.md](../../../../docs/domain/sync.md) — log create applies usage/maintenance side effects |
| **birthdays** | `server/birthdays/` → `/api/birthdays/` | [birthday.md](../../../../docs/domain/birthday.md); [sync.md](../../../../docs/domain/sync.md) |
| **places** | `server/places/` → `/api/places/` | [place.md](../../../../docs/domain/place.md); [sync.md](../../../../docs/domain/sync.md) |
| **auth** | `server/core/` → `/api/auth/` (legacy username/password) | [sync.md](../../../../docs/domain/sync.md) |
| **accounts** | `server/accounts/` → `/api/accounts/` (phone OTP + profile + device registrations) | [user.md](../../../../docs/domain/user.md) |
| **app_config** | `server/app_config/` → `/api/app_config/` (remote feature flags) | [app-config.md](../../../../docs/domain/app-config.md) |
| **sync** | (no separate app) — cursors on resource list endpoints (`updated_since` / `created_since`) | [sync.md](../../../../docs/domain/sync.md) |

Do not invent fields or enum strings outside [`docs/domain/`](../../../../docs/domain/).
