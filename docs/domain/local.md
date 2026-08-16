# Local-only capabilities

Not synced. Do not add server models unless this shard (and the [index](../domain.md)) is updated first. Surfaces: [structure.md](structure.md).

| Capability | Meaning | Where |
|------------|---------|-------|
| **Reminders** | Derived home queue (device due + upcoming birthdays); snooze/prefs on device; local notifications only — not cloud push | client |
| **Home grouping** | Preference: reminders by **device** (default) or by **tag**; tag rows are virtual groups, not Device entities | client |
| **Transfer** | Offline export/import backup (JSON / CSV / text; photos included); import is high-stakes and must state consequences | client |
| **Place** | Named geo point/line/polygon (`kind` + `points[]`); local map — `kind` in [enums.md](enums.md) | client |
| **Preferences** | Language, theme, calendar system (independent of language), soon-window / snooze prefs, home grouping; grouped expandable sections in Preferences | client |
| **App lock** | Optional local gate (password, PIN, or biometric) + idle timeout; secrets stay on device; not synced. Forgot → phone OTP re-auth clears all lock settings to unset | client |
| **First-install intro** | Shown once after splash; prefer online account but allow skip; guest may sign in later from Profile | client |
| **Auth session** | Optional token + cached profile on device; absence = guest / local-only; clearing token = signed out | client |

Index: [../domain.md](../domain.md)
