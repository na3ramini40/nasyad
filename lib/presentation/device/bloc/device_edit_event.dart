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

final class DeviceEditSuggestionApplied extends DeviceEditEvent {
  const DeviceEditSuggestionApplied(this.suggestion);

  final MaintenanceRuleSuggestion suggestion;

  @override
  List<Object?> get props => [suggestion];
}

final class DeviceEditSaveRequested extends DeviceEditEvent {
  const DeviceEditSaveRequested({
    required this.ruleName,
    required this.nameRequiredMessage,
    required this.selectScheduleTypeMessage,
    required this.selectIntervalUnitMessage,
    required this.intervalAmountRequiredMessage,
  });

  final String ruleName;
  final String nameRequiredMessage;
  final String selectScheduleTypeMessage;
  final String selectIntervalUnitMessage;
  final String intervalAmountRequiredMessage;

  @override
  List<Object?> get props => [
        ruleName,
        nameRequiredMessage,
        selectScheduleTypeMessage,
        selectIntervalUnitMessage,
        intervalAmountRequiredMessage,
      ];
}

final class DeviceEditDeleteRequested extends DeviceEditEvent {
  const DeviceEditDeleteRequested();
}
