part of 'device_log_bloc.dart';

enum DeviceLogStatus {
  ready,
  saving,
  saved,
  failure,
}

final class DeviceLogFormState extends Equatable {
  const DeviceLogFormState({
    required this.date,
    this.status = DeviceLogStatus.ready,
    this.notes = '',
    this.usageDelta = '',
    this.usageUnit,
    this.errorMessage,
  });

  final DeviceLogStatus status;
  final String notes;
  final DateTime date;
  final String usageDelta;
  final UsageIntervalUnit? usageUnit;
  final String? errorMessage;

  bool get isSaving => status == DeviceLogStatus.saving;

  DeviceLogFormState copyWith({
    DeviceLogStatus? status,
    String? notes,
    DateTime? date,
    String? usageDelta,
    UsageIntervalUnit? usageUnit,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeviceLogFormState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      usageDelta: usageDelta ?? this.usageDelta,
      usageUnit: usageUnit ?? this.usageUnit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        notes,
        date,
        usageDelta,
        usageUnit,
        errorMessage,
      ];
}
