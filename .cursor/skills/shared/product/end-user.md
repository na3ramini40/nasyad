# End user (living)

Update when facts are stated or proven. Short bullets only.

## Who

- Tracks devices/assets/parts; solo, local-first (works fully offline).
- Optional phone-OTP online account (sign in later anytime); optional remote sync preference (default on) — off or offline keeps data on-device only.
- en and/or fa (RTL). Not a power user: “what’s due?” and “I maintained it.”
- Also remembers people birthdays and map places locally.

## Jobs

1. See due / soon / OK on roots.
2. Confirm maintained (with current usage when linked) or update usage fast.
3. Nest parts without losing whose schedule; children inherit parent usage by default.
4. Trust local data; export/import to move/backup (devices, birthdays, places, tags).
5. Add a birthday (name + month/day) so it can be remembered later.
6. Pick dates in Persian (Shamsi) or Gregorian independently of app language.
7. Open Home for a cross-feature queue (due maintenance + upcoming birthdays), optionally grouped by tag, snooze items, and jump to feature areas from the menu.
8. Save map places (point / path / area) for offline reference.
9. Optionally sign in with phone OTP (then sync local ↔ server when enabled); view/edit a simple profile (name, photo, read-only id); sign out in one tap.
10. Optionally lock the app (password, PIN, or fingerprint) and auto-lock after idle; unlock to continue; forgot lock via phone OTP resets lock to off.

## Model

- First install: intro prefers online but allows continue offline; guest can sign in later from Profile.
- Bottom nav: Home + Profile (guest = Sign in; signed-in = profile).
- Home = reminders queue (sorted by urgency, snoozeable; by device or by tag) + feature menu. Device list lives under Device management.
- Schedule optional (container OK). No schedule ⇒ no next/progress on that node. Usage on nearest usage-owner ancestor; child may opt out with own unit.
- Crossing an interval warns only; maintenance is always an explicit confirm.
- Tags are labels for Home grouping — never devices.
- Archive/delete = whole subtree → high stakes.
- Birthday = name + birth month + birth day (no year required). Calendar preference is for pickers/display, not language.
- Place = name + geometry (point, path, or area) on an offline map.
- Export/import is polymorphic across local data kinds; Drift remains source of truth.
- Online account = phone OTP only; profile id is a server-issued read-only hash.
- On sign-in (when sync preference is on and online), local syncable data is reconciled with the server: conflicts require confirmation; local wins and can override server; skip leaves both sides unchanged; sync failure/skip does not block staying signed in.
- App lock is local-only (not synced); Preferences groups settings in expandable categories.

## Tone

Calm, short, concrete. Action verbs. Status: Needs Service / Due Soon / Up to Date.

## Learned

- Empty home: invite first device, don’t lecture.
- Destructive/import: say the consequence.
- Sync conflict on sign-in: warn before override; local (this device) wins when confirmed.
- Empty birthdays: invite first person, one CTA.
- Sign-out: one tap, no confirmation.
