import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/l10n/app_localizations.dart';

class MaintenanceRuleSuggestion {
  const MaintenanceRuleSuggestion({
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

List<MaintenanceRuleSuggestion> maintenanceRuleSuggestions(
  AppLocalizations l10n,
) {
  return [
    MaintenanceRuleSuggestion(
      label: l10n.ruleEvery3Months,
      scheduleType: ScheduleType.calendarInterval,
      intervalValue: 3,
      intervalUnit: CalendarIntervalUnit.months.storageValue,
    ),
    MaintenanceRuleSuggestion(
      label: l10n.ruleEvery500Hours,
      scheduleType: ScheduleType.usageInterval,
      intervalValue: 500,
      intervalUnit: UsageIntervalUnit.hours.storageValue,
    ),
    MaintenanceRuleSuggestion(
      label: l10n.ruleEvery6Months,
      scheduleType: ScheduleType.calendarInterval,
      intervalValue: 6,
      intervalUnit: CalendarIntervalUnit.months.storageValue,
    ),
  ];
}

String ruleDisplayName({
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
