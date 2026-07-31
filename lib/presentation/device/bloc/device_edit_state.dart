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
    this.parentId,
    this.scheduleEnabled = true,
    this.scheduleType,
    this.intervalUnit,
    this.intervalValue = '',
    this.initialElapsed = '0',
    this.usageUnit,
    this.errorMessage,
  });

  final bool isEdit;
  final DeviceEditStatus status;
  final String name;
  final String? parentId;
  final bool scheduleEnabled;
  final ScheduleType? scheduleType;
  final String? intervalUnit;
  final String intervalValue;
  final String initialElapsed;
  final UsageIntervalUnit? usageUnit;
  final String? errorMessage;

  bool get isBusy =>
      status == DeviceEditStatus.loading || status == DeviceEditStatus.saving;

  DeviceEditState copyWith({
    DeviceEditStatus? status,
    String? name,
    String? parentId,
    bool? scheduleEnabled,
    ScheduleType? scheduleType,
    String? intervalUnit,
    String? intervalValue,
    String? initialElapsed,
    UsageIntervalUnit? usageUnit,
    String? errorMessage,
    bool clearScheduleType = false,
    bool clearIntervalUnit = false,
    bool clearUsageUnit = false,
    bool clearError = false,
  }) {
    return DeviceEditState(
      isEdit: isEdit,
      status: status ?? this.status,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
      scheduleType: clearScheduleType
          ? null
          : (scheduleType ?? this.scheduleType),
      intervalUnit: clearIntervalUnit
          ? null
          : (intervalUnit ?? this.intervalUnit),
      intervalValue: intervalValue ?? this.intervalValue,
      initialElapsed: initialElapsed ?? this.initialElapsed,
      usageUnit: clearUsageUnit ? null : (usageUnit ?? this.usageUnit),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isEdit,
    status,
    name,
    parentId,
    scheduleEnabled,
    scheduleType,
    intervalUnit,
    intervalValue,
    initialElapsed,
    usageUnit,
    errorMessage,
  ];
}
