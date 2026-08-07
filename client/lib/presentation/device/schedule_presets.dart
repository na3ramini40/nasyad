import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/l10n/app_localizations.dart';

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
