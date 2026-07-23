part of 'device_edit_bloc.dart';

enum DeviceEditStatus {
  initial,
  loading,
  ready,
  saving,
  saved,
  deleted,
  failure,
}

final class DeviceEditState extends Equatable {
  const DeviceEditState({
    required this.isEdit,
    this.status = DeviceEditStatus.initial,
    this.name = '',
    this.scheduleType,
    this.intervalUnit,
    this.intervalValue = '',
    this.errorMessage,
  });

  final bool isEdit;
  final DeviceEditStatus status;
  final String name;
  final ScheduleType? scheduleType;
  final String? intervalUnit;
  final String intervalValue;
  final String? errorMessage;

  bool get isBusy =>
      status == DeviceEditStatus.loading || status == DeviceEditStatus.saving;

  DeviceEditState copyWith({
    DeviceEditStatus? status,
    String? name,
    ScheduleType? scheduleType,
    String? intervalUnit,
    String? intervalValue,
    String? errorMessage,
    bool clearScheduleType = false,
    bool clearIntervalUnit = false,
    bool clearError = false,
  }) {
    return DeviceEditState(
      isEdit: isEdit,
      status: status ?? this.status,
      name: name ?? this.name,
      scheduleType: clearScheduleType
          ? null
          : (scheduleType ?? this.scheduleType),
      intervalUnit: clearIntervalUnit
          ? null
          : (intervalUnit ?? this.intervalUnit),
      intervalValue: intervalValue ?? this.intervalValue,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isEdit,
    status,
    name,
    scheduleType,
    intervalUnit,
    intervalValue,
    errorMessage,
  ];
}
