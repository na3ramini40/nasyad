part of 'device_log_bloc.dart';

enum DeviceLogStatus { loading, ready, saving, saved, failure }

final class DeviceLogFormState extends Equatable {
  const DeviceLogFormState({
    required this.date,
    this.status = DeviceLogStatus.loading,
    this.kind = DeviceLogKind.maintenanceDone,
    this.notes = '',
    this.usageValue = '',
    this.usageUnit,
    this.device,
    this.usageOwner,
    this.errorMessage,
  });

  final DeviceLogStatus status;
  final DeviceLogKind kind;
  final String notes;
  final DateTime date;
  final String usageValue;
  final UsageIntervalUnit? usageUnit;
  final Device? device;
  final Device? usageOwner;
  final String? errorMessage;

  bool get isSaving => status == DeviceLogStatus.saving;

  DeviceLogFormState copyWith({
    DeviceLogStatus? status,
    DeviceLogKind? kind,
    String? notes,
    DateTime? date,
    String? usageValue,
    UsageIntervalUnit? usageUnit,
    Device? device,
    Device? usageOwner,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeviceLogFormState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      usageValue: usageValue ?? this.usageValue,
      usageUnit: usageUnit ?? this.usageUnit,
      device: device ?? this.device,
      usageOwner: usageOwner ?? this.usageOwner,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    kind,
    notes,
    date,
    usageValue,
    usageUnit,
    device,
    usageOwner,
    errorMessage,
  ];
}
