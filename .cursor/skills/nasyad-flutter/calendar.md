# Calendar (Gregorian / Persian)

Calendar preference is **independent of app language** (en/fa).

## Storage & state

- `CalendarSystemCubit` on Preferences
- `shared_preferences` via calendar preference store in `lib/core/calendar/`

## Conversion

- Package: `shamsi_date` for Persian month/day
- Pickers: `MonthDayPickerField` and related UI in `lib/core/ui/`

## Birthdays

- Entity: name + birth month + birth day (no year required)
- Display respects calendar preference — Gregorian or Shamsi labels
- Home reminders show upcoming birthdays alongside device maintenance

## UX gates

- Picker labels match selected calendar system, not locale alone.
- Do not require year for birthdays unless product scope expands.

## Code touchpoints

- `lib/domain/entities/birthday.dart`
- `lib/domain/services/birthday_upcoming.dart`
- `lib/presentation/birthday/` pages and blocs

See also `nasyad-ux/end-user.md` for user-facing model.
