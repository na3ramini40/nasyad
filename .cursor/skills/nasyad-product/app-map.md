# App map (living)

Local-first maintenance tracker for devices/assets (tree) and personal birthdays. No cloud/sync. en + fa (RTL). Update this file when screens or user-visible structure changes.

---

## Launch

### Splash
**Entry:** App cold start  
**Shows:** Logo, app name, app version, loading indicator on dark background  
**Actions:** None — automatic (background update check runs after Home loads)  
**Leaves to:** Home when ready (~1s minimum)

### What's new (modal)
**Entry:** First Home visit after app update (not first install)  
**Shows:** Version label and changelog bullets (en/fa)  
**Actions:** Dismiss  
**Leaves to:** Home (stays on Home)

---

## Home

**Entry:** After splash; back from sub-features  
**Shows:**
- App bar: logo mark, app title, search icon, settings icon
- **Reminders** section: filter chips (All / Devices / Birthdays)
- Optional **update available** banner when a newer GitHub release exists (tap → update dialog)
- Reminder rows: title, subtitle (due/soon/today/tomorrow/in N days), urgency badge (Due / Soon / Upcoming), kind icon
- Empty reminders: check icon, “nothing due” title + hint
- **Features** section: menu tiles
- Loading spinner while data loads; error message on failure

**Actions:**
- Filter chips narrow the reminder list
- Tap reminder → device detail (maintenance) or birthday edit (birthday)
- Device reminder overflow (⋮) → quick actions sheet: log maintenance or update usage (opens add-log with kind preselected)
- Device management tile → device list
- Birthdays tile → birthday list
- Settings → preferences

**Leaves to:** Device detail, birthday edit, device list, birthday list, preferences, search

---

## Device management

### Device list
**Entry:** Home → Device management; Preferences → Birthdays shortcut is separate  
**Shows:** Root devices as cards — name, status badge (Up to Date / Due Soon / Needs Service), progress bar, last log summary; empty state with logo + add-first hint  
**Actions:** Tap card → device detail; FAB → add root device; app bar archive icon → archived devices; app bar search → search  
**Leaves to:** Device detail, add device, archived devices, search

### Archived devices
**Entry:** Device list app bar; Preferences → Data  
**Shows:** Archived device entries (root of each archived subtree) as list rows with restore action; empty state when nothing archived  
**Actions:** Restore (confirms — device and all its parts return to active list)  
**Leaves to:** Previous screen (list updates live)

### Add / edit device
**Entry:** Device list FAB; device detail edit; add child from device detail  
**Shows:** Name; optional schedule (type, interval, initial elapsed); usage unit for usage-based roots; **schedule templates** picker when schedule is enabled (bundled presets with en/fa labels, e.g. oil change, HVAC filter)  
**Actions:** Save; pick a template to fill schedule fields; delete (edit only, confirms)  
**Leaves to:** Previous screen

### Device detail
**Entry:** Device list; home reminder; child card from parent  
**Shows:** Name, status badge, progress bar (if scheduled), schedule card, children list (or add-child row), log history  
**Actions:** Archive (subtree); edit; FAB → add log; tap child → child detail; add child  
**Leaves to:** Edit device, add log, child detail, Home (after archive)

### Add log
**Entry:** Device detail FAB (maintenance default; usage if linked)  
**Shows:** Kind (maintenance done / usage update), date, optional notes; usage field when relevant  
**Actions:** Save  
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

## Preferences

**Entry:** Home settings icon  
**Shows:** Language (en/fa); calendar system (Gregorian/Persian); season theme (default / spring / summer / autumn / winter, each with light and dark variants); brightness (system/light/dark); due reminder notifications (enable + daily time, on supported platforms); data links (birthdays, archived devices, export/import); about (app name + version, what's new, check for updates with status)  
**Actions:** Change settings; toggle/reschedule local due reminders; pick notification time; open birthdays; open archived devices; open export/import; open what's new dialog; check for updates (manual)  
**Leaves to:** Birthday list, archived devices, export/import, what's new modal, update download/install dialog

### Export & import
**Entry:** Preferences → Export & import  
**Shows:** Export scope (all / one / selected), format (JSON / CSV / plain text), device picker when needed; import file picker  
**Actions:** Export (share/save/copy); import file  
**Leaves to:** Preferences (snackbar feedback)

---

## Search

**Entry:** Home app bar search icon; Device list app bar search icon  
**Shows:** Search field; prompt when empty; grouped results (Devices / Birthdays) with name and path or birthday date; empty state when no matches  
**Actions:** Type to search; tap device → device detail; tap birthday → birthday edit  
**Leaves to:** Device detail, birthday edit

---

## Global patterns

- **Status labels:** Up to Date · Due Soon · Needs Service (devices); Due · Soon · Upcoming (home badges)
- **Back:** App bar back or system back returns to previous screen
- **Data:** All on device; export/import for backup and move
- **Local due reminders:** On-device scheduled notifications for due/soon maintenance and upcoming birthdays (not cloud push). Tap opens device detail or birthday edit. Reschedules when data or preferences change.
- **Tree:** Devices nest; schedule optional per node; archive/delete removes whole subtree
