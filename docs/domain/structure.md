# Structure

What the product **is** and what every conforming implementation must support. Screen layout/copy → product app-map; this file owns capabilities and acceptance semantics.

## Identity

Local-first maintenance tracking for devices/assets (hierarchical) and recurring personal follow-ups (birthdays). Optional remote sync does not change local-first semantics.

## Capabilities (must hold)

| # | Rule | Where |
|---|------|-------|
| 1 | Users create and manage tracked items in a **tree** (children of children allowed) | both |
| 2 | Any node may have an optional maintenance schedule: calendar interval, usage interval, or fixed date — including an initial “already elapsed” offset | both |
| 3 | Usage-based schedules share one usage reading on the nearest usage-owner ancestor (children inherit by default; opt out by setting own `usage_unit`); calendar schedules progress by wall clock | both |
| 4 | Users update usage (absolute reading) or confirm maintenance (resets **that** node’s cycle only; with a usage owner, maintenance also records the absolute reading) | both |
| 5 | Archive / delete cascades to the **entire subtree** | both |
| 6 | Due / soon / progress / remaining / target are **computed** from schedule + last maintenance + usage — not stored fields; no schedule ⇒ no own next/progress | both |
| 7 | Parent status = worst of own schedule (if any) and each child’s aggregate; roots expose that for list/home | client |
| 8 | Opening a device exposes schedule progress (remaining + target when usage), nested children, log history, and an always-available maintain action | client |
| 8a | Client can share a human-readable **PDF** of maintenance history for a device subtree (not Transfer backup); empty subtree does not share | client |
| 9 | Home exposes a reminders queue (due maintenance + upcoming birthdays) with filters, plus a feature menu; grouping may be **by device** or **by tag** | client |
| 9a | **Tags** are local labels (not devices). Tag mode on Home shows one row per tag with rollup status; user never treats a tag as an asset device | client |
| 10 | Preferences include language, theme, calendar system, app lock, and entry to data transfer; settings are grouped in expandable categories | client |
| 10a | Optional **app lock**: method is password, PIN, or biometric; idle timeout locks the app until unlock; forgot lock uses existing phone OTP and resets lock to unset | client |
| 11 | Export / import: scope (all / one / selected), formats (JSON / CSV / plain text), share or save; import from file | client |
| 12 | Network sync is optional; product must remain correct with local store only | client |
| 13 | When sync is enabled: idempotent upsert by client id, owner isolation, cursors per [sync.md](sync.md) | server |
| 14 | Optional online account via phone OTP; profile (name, image, read-only server `id` hash); sign-out | both |
| 14a | Signed-in installs register a per-device FCM token (`device_id` + `fcm_token`) for server push targeting; multi-install per user supported | both |
| 15 | First install: intro prefers online but allows skip to local-only; guest can sign in later | client |
| 16 | Bottom nav includes Home and Profile; Profile is Sign-in when guest, profile when signed in | client |
| 17 | Optional remote **app config** (feature flags): server evaluates flags; client caches and applies without blocking local-first use — [app-config.md](app-config.md) | both |

## Surfaces (logical)

Not UI widgets — named places a client must provide. Any UI toolkit maps to these.

| Surface | Shows / does |
|---------|----------------|
| **Home** | Reminders queue (due maintenance, upcoming birthdays) + filters + feature menu; optional device vs tag grouping |
| **Device list** | Root devices: latest log summary, aggregate due status + progress |
| **Device edit** | Name; optional schedule + initial elapsed; usage unit (roots, or child opt-out); optional tags |
| **Device detail** | Status, schedule progress (remaining/target when usage), children, logs; maintain; add child; add log; share maintenance history (PDF) |
| **Log edit** | Kind: maintenance done or usage update; usage reading when required (+ optional cost/vendor/photo) |
| **Tag manage** | Create/rename/delete local tags; assign devices to tags (tags are not devices) |
| **Birthday list / edit** | People: name + month/day + calendar system |
| **Preferences** | Expandable categories: app lock, language & region, reminders, appearance, sync, data, about |
| **App unlock** | Full-screen gate when locked; unlock via configured method; forgot → phone OTP then lock cleared |
| **Transfer** | Export/import as in capability 11 |
| **Intro** | First install: prefer sign-in / allow offline skip |
| **Sign-in** | Phone OTP request + verify (+ resend cooldown) |
| **Profile** | Guest: sign-in CTA. Signed-in: view/edit name & image; read-only id; sign out |

Entity detail: [device.md](device.md), [device-log.md](device-log.md), [birthday.md](birthday.md), [user.md](user.md), [local.md](local.md). Index: [../domain.md](../domain.md)
