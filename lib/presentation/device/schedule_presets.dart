import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/l10n/app_localizations.dart';

class ScheduleSuggestion {
  const ScheduleSuggestion({
    required this.label,
    required this.scheduleType,
    required this.intervalValue,
    required this.intervalUnit,
  });

  final String label;
  final ScheduleType scheduleType;
  final int intervalValue;
  final String intervalUnit;
}

List<ScheduleSuggestion> scheduleSuggestions(AppLocalizations l10n) {
  return [
    ScheduleSuggestion(
      label: l10n.ruleEvery3Months,
      scheduleType: ScheduleType.calendarInterval,
      intervalValue: 3,
      intervalUnit: CalendarIntervalUnit.months.storageValue,
    ),
    ScheduleSuggestion(
      label: l10n.ruleEvery6Months,
      scheduleType: ScheduleType.calendarInterval,
      intervalValue: 6,
      intervalUnit: CalendarIntervalUnit.months.storageValue,
    ),
    ScheduleSuggestion(
      label: l10n.ruleEvery1000Km,
      scheduleType: ScheduleType.usageInterval,
      intervalValue: 1000,
      intervalUnit: UsageIntervalUnit.km.storageValue,
    ),
    ScheduleSuggestion(
      label: l10n.ruleEvery500Hours,
      scheduleType: ScheduleType.usageInterval,
      intervalValue: 500,
      intervalUnit: UsageIntervalUnit.hours.storageValue,
    ),
  ];
}

String scheduleDisplayName({
  required AppLocalizations l10n,
  required int value,
  required String unitStorage,
}) {
  final unitLabel = switch (unitStorage) {
    'days' => l10n.unitDays,
    'weeks' => l10n.unitWeeks,
    'months' => l10n.unitMonths,
    'hours' => l10n.unitHours,
    'km' => l10n.unitKm,
    'cycles' => l10n.unitCycles,
    _ => unitStorage,
  };
  return l10n.ruleEvery(value, unitLabel);
}

String usageUnitLabel(AppLocalizations l10n, UsageIntervalUnit unit) {
  return switch (unit) {
    UsageIntervalUnit.hours => l10n.unitHours,
    UsageIntervalUnit.km => l10n.unitKm,
    UsageIntervalUnit.cycles => l10n.unitCycles,
  };
}
