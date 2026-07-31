part of 'device_log_bloc.dart';

sealed class DeviceLogEvent extends Equatable {
  const DeviceLogEvent();

  @override
  List<Object?> get props => [];
}

final class DeviceLogStarted extends DeviceLogEvent {
  const DeviceLogStarted();
}

final class DeviceLogKindChanged extends DeviceLogEvent {
  const DeviceLogKindChanged(this.kind);

  final DeviceLogKind kind;

  @override
  List<Object?> get props => [kind];
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

final class DeviceLogUsageValueChanged extends DeviceLogEvent {
  const DeviceLogUsageValueChanged(this.usageValue);

  final String usageValue;

  @override
  List<Object?> get props => [usageValue];
}

final class DeviceLogSubmitRequested extends DeviceLogEvent {
  const DeviceLogSubmitRequested({required this.usageReadingRequiredMessage});

  final String usageReadingRequiredMessage;

  @override
  List<Object?> get props => [usageReadingRequiredMessage];
}
