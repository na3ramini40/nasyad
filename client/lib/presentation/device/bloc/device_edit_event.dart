part of 'device_edit_bloc.dart';

sealed class DeviceEditEvent extends Equatable {
  const DeviceEditEvent();

  @override
  List<Object?> get props => [];
}

final class DeviceEditStarted extends DeviceEditEvent {
  const DeviceEditStarted();
}

final class DeviceEditNameChanged extends DeviceEditEvent {
  const DeviceEditNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class DeviceEditCategoryPresetChanged extends DeviceEditEvent {
  const DeviceEditCategoryPresetChanged(this.categoryPreset);

  final DeviceCategoryPreset? categoryPreset;

  @override
  List<Object?> get props => [categoryPreset];
}

final class DeviceEditLocationLabelChanged extends DeviceEditEvent {
  const DeviceEditLocationLabelChanged(this.locationLabel);

  final String locationLabel;

  @override
  List<Object?> get props => [locationLabel];
}

final class DeviceEditNotesChanged extends DeviceEditEvent {
  const DeviceEditNotesChanged(this.notes);

  final String notes;

  @override
  List<Object?> get props => [notes];
}

final class DeviceEditScheduleEnabledChanged extends DeviceEditEvent {
  const DeviceEditScheduleEnabledChanged(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class DeviceEditScheduleTypeChanged extends DeviceEditEvent {
  const DeviceEditScheduleTypeChanged(this.scheduleType);

  final ScheduleType scheduleType;

  @override
  List<Object?> get props => [scheduleType];
}

final class DeviceEditIntervalChanged extends DeviceEditEvent {
  const DeviceEditIntervalChanged(this.intervalValue);

  final String intervalValue;

  @override
  List<Object?> get props => [intervalValue];
}

final class DeviceEditIntervalUnitChanged extends DeviceEditEvent {
  const DeviceEditIntervalUnitChanged(this.intervalUnit);

  final String intervalUnit;

  @override
  List<Object?> get props => [intervalUnit];
}

final class DeviceEditInitialElapsedChanged extends DeviceEditEvent {
  const DeviceEditInitialElapsedChanged(this.initialElapsed);

  final String initialElapsed;

  @override
  List<Object?> get props => [initialElapsed];
}

final class DeviceEditUsageUnitChanged extends DeviceEditEvent {
  const DeviceEditUsageUnitChanged(this.usageUnit);

  final UsageIntervalUnit usageUnit;

  @override
  List<Object?> get props => [usageUnit];
}

final class DeviceEditTemplateApplied extends DeviceEditEvent {
  const DeviceEditTemplateApplied(this.template);

  final ScheduleTemplate template;

  @override
  List<Object?> get props => [template];
}

final class DeviceEditSaveRequested extends DeviceEditEvent {
  const DeviceEditSaveRequested({
    required this.nameRequiredMessage,
    required this.selectScheduleTypeMessage,
    required this.selectIntervalUnitMessage,
    required this.intervalAmountRequiredMessage,
  });

  final String nameRequiredMessage;
  final String selectScheduleTypeMessage;
  final String selectIntervalUnitMessage;
  final String intervalAmountRequiredMessage;

  @override
  List<Object?> get props => [
    nameRequiredMessage,
    selectScheduleTypeMessage,
    selectIntervalUnitMessage,
    intervalAmountRequiredMessage,
  ];
}

final class DeviceEditDeleteRequested extends DeviceEditEvent {
  const DeviceEditDeleteRequested();
}
