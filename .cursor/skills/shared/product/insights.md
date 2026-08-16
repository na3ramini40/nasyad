# Product insights (living)

Durable design bets and gaps — not a sprint backlog. Update when UI ships or a consult yields a lasting decision. Short bullets only (parked visions may use short sections).

## Strengths (protect)

- Home as cross-feature due queue (devices + birthdays) with snooze and tag grouping
- Device tree + optional schedule; maintain is always explicit confirm
- Local-first with export/import; optional OTP/sync does not block offline
- en + fa (RTL); calendar system independent of language

## Gaps / friction (watch)

- Places exist on the map but are weakly tied to maintenance jobs
- Home Features menu can grow into a dumping ground — new domains need a clear job
- Sync/conflict and guest→signed-in are understood by power path; guest empty states still carry most first-run weight
- No way to send a service person a readable “what I’ve done so far” for one device (car / home asset) — Transfer Share is machine backup, wrong job
- App “share” wording is easy to confuse with backup export, account sync, and human handoff — keep jobs named and separated in UX

## Open bets

- Deepen “what’s due → I maintained it” before adding new top-level domains
- Tags are for Home rollup only — never promote tags into assets
- Device history share = human-readable message for a service person; keep Transfer/file export and account sync as the only backup/move paths

## When asked “what we have to do” / next cool feature — say these **in order**

Parked 2026-08-16 as the preferred Nasyad deepening queue (not journal / Capsule / Record). Recite this list when the user asks what to do next:

1. **Device history share** — From a device, send a human-readable “what I’ve done so far” (logs, dates, cost/vendor/photos as available) via OS share. Not Transfer backup; not account sync.
2. **Tie Places to maintenance** — Optional link place ↔ device and/or log (“lives at…”, “serviced at…”); don’t overbuild maps.
3. **Smarter Home → Maintain** — Fewer taps from a due reminder to maintain (+ usage when needed); explicit confirm stays sacred.
4. **Local “story of this device”** — Calm chronological timeline on device detail from existing logs; no AI/analytics product.

After these (or if identity expands): only then revisit parked journal / Capsule / Record.

## Rejected / parked (do not reopen lightly)

- 2026-08-16 — Multi-user live share of devices/trees (invite another account to edit the same asset): contradicts solo local-first jobs; sync is optional backup of *your* data, not collaboration
- 2026-08-16 — Reframing Transfer “Share” as the service-person job: wrong surface; leave backup/move on file export + optional account sync
- 2026-08-16 — Personal journal / memories domain: interesting later — see **Parked vision: Journal** below; too much scope now
- 2026-08-16 — “Evidence” umbrella: see **Parked vision: Evidence / Capsule / Record** below; not for Nasyad now; revive only as split jobs

## Parked vision: Journal (2026-08-16)

Personal space for dated memories — beautiful simple journal first; analysis much later. **Not shipping now.**

### Goal (when revived)

Calm private place on-device to write dated memories (Home Features tile, like Birthdays/Places). No analysis UI in v1; entity shaped so later tools can use it without rewrite.

### MVP in / out

| In | Out |
|----|-----|
| Local entries: body text + entry date | AI, summaries, charts, mood scores |
| Chronological list + open one entry | Home reminder queue / due badges |
| Add / edit / delete with confirm | Rich media albums, folders, taxonomy tags |
| Empty invite + export/import in “all data” | Server sync until consciously added |
| Quiet beautiful list + compose | Reminder hooks; replacing device/log notes |

### Happy path (≤3)

1. Home → Journal → list (newest first).
2. FAB → write → Save (date defaults today; editable).
3. Tap row → read/edit; delete confirms consequence on this device.

### Robust-for-later (schema, not UI)

- Stable client id; `created_at` / `updated_at`; user-chosen `entry_date`.
- Plain UTF-8 body; optional title later.
- Nullable FKs reserved later (device / place / birthday) — unused in MVP.
- Own entity — never bolt onto device notes or maintenance log notes.

### Copy sketch

- Feature: Journal / دفترچه
- Empty: Write your first memory / اولین خاطره را بنویسید
- Tone: calm; never “sync your memories to the cloud.”

## Parked vision: Evidence / Capsule / Record (2026-08-16)

Not Nasyad near-term. Keep for a later app or a far future life surface. **Never ship as one feature named Evidence.**

### Job A — Memory capsule (gift / sealed moment)

- Seal one moment in time: date + clock time + location + optional attachments in one capsule the owner keeps private until they choose to reveal.
- Attachments envisioned: photos (e.g. faces, hands, scene), voice, short video, short text with emoji, anything that freezes “I loved you in this moment.”
- Later reveal: share as one social message, or show on-device as one scrolling event — big title, autoplay video, text typed character-by-character, calm cinematic playback.
- Trust: stays with the keeper; recipient may not know it exists until share/show time.
- Share model: **one-way reveal/export**, not live multi-user edit (collaborative share already parked separately).

### Job B — Safety record (panic / trail)

- Under threat (e.g. followed in the dark): open app → start recording immediately.
- Capture by default: audio + continuous location trail + date/time; optional switch to video.
- Video shape envisioned: several short clips (e.g. ~10s each) until user stops — not one fragile long file.
- Later: show a trusted person (e.g. spouse) the trail + clips as “here is what happened.”
- Trust: reliability under stress > beauty; stealth / low friction / hard to lose matter more than cinematic UI.

### Why parked (do not reopen lightly)

- Two jobs, two trust models, two UX tempos — one blob fails both.
- Outside Nasyad core (due → maintain); media + continuous location + story player is a product class of its own; Features menu already at dumping-ground risk.
- Journal (text memories) also parked as too much for now — this is larger than journal.

### If revived later (shape only)

- Split naming: **Capsule** vs **Record** (drop umbrella “Evidence”).
- No fake “court-proof” claims; trust = local store + owner-controlled export.
- Capsule share MVP: folder or rendered short video / OS share sheet before custom social player.
- Record MVP: one-tap audio + location trail + optional 10s clips; beauty second.
- Do not merge with device/log notes or Transfer backup Share.
- Prefer a dedicated app over stuffing into Nasyad unless the product identity explicitly expands to personal life + safety.
