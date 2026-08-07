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
    this.categoryPreset,
    this.locationLabel = '',
    this.notes = '',
    this.parentId,
    this.scheduleEnabled = true,
    this.scheduleType,
    this.intervalUnit,
    this.intervalValue = '',
    this.initialElapsed = '0',
    this.fixedDueAt,
    this.usageUnit,
    this.templates = const [],
    this.appliedTemplateId,
    this.errorMessage,
  });

  final bool isEdit;
  final DeviceEditStatus status;
  final String name;
  final DeviceCategoryPreset? categoryPreset;
  final String locationLabel;
  final String notes;
  final String? parentId;
  final bool scheduleEnabled;
  final ScheduleType? scheduleType;
  final String? intervalUnit;
  final String intervalValue;
  final String initialElapsed;
  final DateTime? fixedDueAt;
  final UsageIntervalUnit? usageUnit;
  final List<ScheduleTemplate> templates;
  final String? appliedTemplateId;
  final String? errorMessage;

  bool get isBusy =>
      status == DeviceEditStatus.loading || status == DeviceEditStatus.saving;

  DeviceEditState copyWith({
    DeviceEditStatus? status,
    String? name,
    DeviceCategoryPreset? categoryPreset,
    String? locationLabel,
    String? notes,
    String? parentId,
    bool? scheduleEnabled,
    ScheduleType? scheduleType,
    String? intervalUnit,
    String? intervalValue,
    String? initialElapsed,
    DateTime? fixedDueAt,
    UsageIntervalUnit? usageUnit,
    List<ScheduleTemplate>? templates,
    String? appliedTemplateId,
    String? errorMessage,
    bool clearScheduleType = false,
    bool clearIntervalUnit = false,
    bool clearUsageUnit = false,
    bool clearFixedDueAt = false,
    bool clearError = false,
  }) {
    return DeviceEditState(
      isEdit: isEdit,
      status: status ?? this.status,
      name: name ?? this.name,
      categoryPreset: categoryPreset ?? this.categoryPreset,
      locationLabel: locationLabel ?? this.locationLabel,
      notes: notes ?? this.notes,
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
      fixedDueAt: clearFixedDueAt ? null : (fixedDueAt ?? this.fixedDueAt),
      usageUnit: clearUsageUnit ? null : (usageUnit ?? this.usageUnit),
      templates: templates ?? this.templates,
      appliedTemplateId: appliedTemplateId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isEdit,
    status,
    name,
    categoryPreset,
    locationLabel,
    notes,
    parentId,
    scheduleEnabled,
    scheduleType,
    intervalUnit,
    intervalValue,
    initialElapsed,
    fixedDueAt,
    usageUnit,
    templates,
    appliedTemplateId,
    errorMessage,
  ];
}
