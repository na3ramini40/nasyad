part of 'device_log_bloc.dart';

sealed class DeviceLogEvent extends Equatable {
  const DeviceLogEvent();

  @override
  List<Object?> get props => [];
}

final class DeviceLogNotesChanged extends DeviceLogEvent {
  const DeviceLogNotesChanged(this.notes);

  final String notes;

  @override
  List<Object?> get props => [notes];
}

final class DeviceLogDateChanged extends DeviceLogEvent {
  const DeviceLogDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class DeviceLogUsageDeltaChanged extends DeviceLogEvent {
  const DeviceLogUsageDeltaChanged(this.usageDelta);

  final String usageDelta;

  @override
  List<Object?> get props => [usageDelta];
}

final class DeviceLogUsageUnitChanged extends DeviceLogEvent {
  const DeviceLogUsageUnitChanged(this.usageUnit);

  final UsageIntervalUnit usageUnit;

  @override
  List<Object?> get props => [usageUnit];
}

final class DeviceLogSubmitRequested extends DeviceLogEvent {
  const DeviceLogSubmitRequested({required this.usageUnitRequiredMessage});

  final String usageUnitRequiredMessage;

  @override
  List<Object?> get props => [usageUnitRequiredMessage];
}
