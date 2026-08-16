# App map (living)

Local-first maintenance tracker for devices/assets (tree) and personal birthdays. Optional phone-OTP account. en + fa (RTL). Update this file when screens or user-visible structure changes.

---

## Launch

### Splash
**Entry:** App cold start  
**Shows:** Logo, app name, app version, loading indicator on dark background  
**Actions:** None — automatic (background update check runs after Home loads)  
**Leaves to:** Intro on first install; otherwise Home (shell) when ready (~1s minimum)

### Intro (first install only)
**Entry:** Splash when intro not yet completed  
**Shows:** Prefer-online message; primary Sign in with phone; secondary Continue offline  
**Actions:** Sign in → phone OTP; Continue offline → Home as guest (intro marked done)  
**Leaves to:** Auth phone flow or Home shell

### What's new (modal)
**Entry:** First Home visit after app update (not first install)  
**Shows:** Version label and changelog bullets (en/fa)  
**Actions:** Dismiss  
**Leaves to:** Home (stays on Home)

---

## Shell (bottom nav)

**Entry:** After splash/intro  
**Shows:** Bottom tabs — **Home**, **Profile**  
**Actions:** Switch tabs  
**Leaves to:** Home content or Profile (guest or signed-in)

---

## Home

**Entry:** Shell Home tab; back from sub-features  
**Shows:**
- App bar: logo mark, app title, search icon, settings icon
- **Reminders** section: filter chips (All / Devices / Birthdays); grouping control (by device / by tag)
- Optional **update available** banner when a newer GitHub release exists (tap → update dialog)
- Reminder rows: title, subtitle (due/soon/today/tomorrow/in N days; usage remaining/target when relevant), urgency badge (Due / Soon / Upcoming), kind icon; snooze action hides a row for 1/3/7 days
- Tag-mode rows: tag name + rollup warning (not a device); tap expands or opens first due device in the tag
- Empty reminders: check icon, “nothing due” title + hint
- **Features** section: menu tiles
- Loading spinner while data loads; error message on failure

**Actions:**
- Filter chips narrow the reminder list
- Switch Home grouping (device vs tag)
- Snooze reminder (1 / 3 / 7 days) — row returns after the snooze period
- Tap reminder → device detail (maintenance) or birthday edit (birthday)
- Device reminder overflow (⋮) → quick actions sheet: log maintenance or update usage (opens add-log with kind preselected)
- Device management tile → device list
- Birthdays tile → birthday list
- Places tile → place list
- Settings → preferences

**Leaves to:** Device detail, birthday edit, device list, birthday list, place list, preferences, search

---

## Account

### Sign in (phone OTP)
**Entry:** Intro primary CTA; Profile guest Sign in  
**Shows:** Phone field → send code; OTP field with resend countdown (2 minutes); after verify, brief “Syncing your data…”; if the same items differ on device vs server, a confirm dialog (keep device data / skip sync)  
**Actions:** Send code; Verify; Resend when cooldown ends; on conflict confirm keep local (updates server) or skip sync  
**Leaves to:** Home shell (signed in) on success — sync failure or skip keeps local data safe and still enters Home (soft snackbar when relevant)

### Profile (guest)
**Entry:** Shell Profile tab when signed out  
**Shows:** Sign in CTA only  
**Actions:** Sign in → phone OTP  
**Leaves to:** Auth phone flow

### Profile (signed in)
**Entry:** Shell Profile tab when signed in  
**Shows:** Name, image, phone, read-only account id (hash); edit and sign-out actions  
**Actions:** Edit profile; Sign out (one tap, no confirm) → guest Profile  
**Leaves to:** Profile edit; stays on Profile after sign-out

### Profile edit
**Entry:** Profile → edit  
**Shows:** Name field; image picker; read-only id  
**Actions:** Save; change photo  
**Leaves to:** Profile

---

## Device management

### Device list
**Entry:** Home → Device management; Preferences → Birthdays shortcut is separate  
**Shows:** Root devices as cards — category icon, name, optional location label, status badge (Up to Date / Due Soon / Needs Service), progress bar, last log summary; empty state with logo + add-first hint  
**Actions:** Tap card → device detail; FAB → add root device; app bar archive icon → archived devices; app bar search → search  
**Leaves to:** Device detail, add device, archived devices, search

### Archived devices
**Entry:** Device list app bar; Preferences → Data  
**Shows:** Archived device entries (root of each archived subtree) as list rows with restore action; empty state when nothing archived  
**Actions:** Restore (confirms — device and all its parts return to active list)  
**Leaves to:** Previous screen (list updates live)

### Add / edit device
**Entry:** Device list FAB; device detail edit; add child from device detail  
**Shows:** Name; optional category icon preset; optional location label; optional device notes; optional schedule (type, interval, initial elapsed); usage unit for roots; for children, “use parent usage” (default on) or own usage unit; optional tags; **schedule templates** picker when schedule is enabled (bundled presets with en/fa labels, e.g. oil change, HVAC filter)  
**Actions:** Save; pick a template to fill schedule fields; manage tags; delete (edit only, confirms)  
**Leaves to:** Previous screen

### Device detail
**Entry:** Device list; home reminder; child card from parent  
**Shows:** Name, category icon, optional location label, optional device notes, status badge, progress bar (if scheduled), remaining + target when usage schedule, schedule card or add-schedule hint, children list (or add-child row), log history (date, cost, vendor, photo thumbnail when present)  
**Actions:** Archive (subtree); edit; primary Maintain (confirm + current usage when linked); FAB → add log / update usage; tap child → child detail; add child  
**Leaves to:** Edit device, add log, child detail, Home (after archive)

### Add log
**Entry:** Device detail FAB (maintenance default; usage if linked); Maintain CTA  
**Shows:** Kind (maintenance done / usage update), date, optional notes; usage field required for usage update and for maintain when a usage owner exists; optional cost (amount + currency label), vendor/service provider, photo attachment  
**Actions:** Save; attach or remove photo  
**Leaves to:** Device detail

---

## Birthdays

### Birthday list
**Entry:** Home → Birthdays; Preferences → Birthdays  
**Shows:** People with formatted month/day (respects calendar preference); empty state + hint  
**Actions:** Tap → edit; swipe/delete with confirm; FAB → add  
**Leaves to:** Add/edit birthday

### Add / edit birthday
**Entry:** List FAB; home birthday reminder; list tap  
**Shows:** Name; month/day picker (Gregorian or Persian per preference)  
**Actions:** Save; delete (edit, confirms)  
**Leaves to:** Birthday list or Home

---

## Places

### Place list
**Entry:** Home → Places  
**Shows:** Saved places as list rows (name + kind summary: point/path/area); empty state + add hint  
**Actions:** Tap → edit; delete with confirm; FAB → add  
**Leaves to:** Add/edit place

### Add / edit place
**Entry:** List FAB; list tap; search place result  
**Shows:** Name; kind (point / path / area); map canvas to tap points; use-my-location; undo last point  
**Actions:** Save; delete (edit, confirms)  
**Leaves to:** Place list

---

## Preferences

**Entry:** Home settings icon  
**Shows:** Expandable categories (collapsed by default):
- **App lock** — method (Off / Password / PIN / Fingerprint), idle timeout; setup/change/disable
- **Language & region** — language (en/fa); calendar system (Gregorian/Persian)
- **Reminders** — soon window (7 / 14 days); due reminder notifications (enable + daily time, on supported platforms)
- **Appearance** — season theme (default / spring / summer / autumn / winter / color blind); brightness (system/light/dark); display size (slider + two-finger pinch; reset)
- **Sync** — sync with remote toggle (default on) + status
- **Data** — birthdays, archived devices, export/import links
- **About** — app name + version, what's new, check for updates with status

**Actions:** Expand a category; change settings; set/change/disable app lock; toggle remote sync; toggle/reschedule local due reminders; open birthdays / archived devices / export/import; open what's new; check for updates  
**Leaves to:** Birthday list, archived devices, export/import, what's new modal, update download/install dialog, app lock setup

### App unlock
**Entry:** Cold start or idle timeout when app lock is enabled  
**Shows:** Unlock UI for the configured method (password, PIN, or biometric); Forgot lock link  
**Actions:** Unlock with method; Forgot → phone OTP (`purpose=reset_lock`) — on success lock settings reset to Off  
**Leaves to:** Previous app content (unlocked); Home after forgot-reset

### Export & import
**Entry:** Preferences → Export & import  
**Shows:** Export scope (all data / one device / selected devices), format (JSON / CSV / plain text), device picker when needed; import file picker with preview counts (devices, logs, birthdays, places)  
**Actions:** Export (share/save/copy) — all data includes devices, birthdays, and places; import file (merges/restores those kinds)  
**Leaves to:** Preferences (snackbar feedback)

---

## Search

**Entry:** Home app bar search icon; Device list app bar search icon  
**Shows:** Search field; prompt when empty; grouped results (Devices / Birthdays / Places) with name and path, birthday date, or place kind; empty state when no matches  
**Actions:** Type to search; tap device → device detail; tap birthday → birthday edit; tap place → place edit  
**Leaves to:** Device detail, birthday edit, place edit

---

## Global patterns

- **Status labels:** Up to Date · Due Soon · Needs Service (devices); Due · Soon · Upcoming (home badges)
- **Back:** App bar back or system back returns to previous screen
- **Data:** Local-first on device (Drift); export/import for backup and move; optional remote sync preference does not block offline use
- **Local due reminders:** On-device scheduled notifications for due/soon maintenance and upcoming birthdays (not cloud push). Tap opens device detail or birthday edit. Reschedules when data or preferences change.
- **Tree:** Devices nest; schedule optional per node; archive/delete removes whole subtree
