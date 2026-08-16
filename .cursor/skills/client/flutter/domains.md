# Client domains

**Bible:** [`docs/domain.md`](../../../../docs/domain.md) → [`docs/domain/`](../../../../docs/domain/) (structure + Where-tagged rules). Outcomes must match any stack.
Server paths: `.cursor/skills/server/django/domains.md`.

| Domain | Presentation / usecases | Drift | Shard |
|--------|------------------------|-------|--------|
| **device** | `device/`, + `device_log/` usecases | `devices_table`, `device_logs_table` | [device.md](../../../../docs/domain/device.md), [device-log.md](../../../../docs/domain/device-log.md) |
| **birthday** | `birthday/` | `birthdays_table` | [birthday.md](../../../../docs/domain/birthday.md) |
| **reminders** | `home/`, `usecases/home/` | — | [local.md](../../../../docs/domain/local.md), [structure.md](../../../../docs/domain/structure.md) |
| **transfer** | `transfer/` | — | [local.md](../../../../docs/domain/local.md) |
| **place** | `place/` | `places_table` | [local.md](../../../../docs/domain/local.md) |
| **tag** | `tag/`, device edit chips, home grouping | `tags_table`, `device_tags` (syncable) | [tag.md](../../../../docs/domain/tag.md), [sync.md](../../../../docs/domain/sync.md) |
| **auth / profile** | `auth/`, `profile/`, intro under splash or `intro/` | session prefs (token + intro flag); optional cached profile; install `device_id` + FCM token prefs; silent registration upsert | [user.md](../../../../docs/domain/user.md), [local.md](../../../../docs/domain/local.md) |
| **app_lock** | `app_lock/` — gate + Preferences section; prefs + secure storage (not Drift) | — | [local.md](../../../../docs/domain/local.md) |
| **app_config** | (no chrome) — fetch/cache/apply via repository + cubit; SharedPreferences cache | — | [app-config.md](../../../../docs/domain/app-config.md) |

Cross-domain deps go through repository contracts, never another feature’s UI.
