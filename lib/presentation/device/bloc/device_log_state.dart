part of 'device_log_bloc.dart';

enum DeviceLogStatus { loading, ready, saving, saved, failure }

final class DeviceLogFormState extends Equatable {
  const DeviceLogFormState({
    required this.date,
    this.status = DeviceLogStatus.loading,
    this.kind = DeviceLogKind.maintenanceDone,
    this.notes = '',
    this.usageValue = '',
    this.costValue = '',
    this.costCurrency = '',
    this.vendor = '',
    this.photoBytes,
    this.photoFileName,
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
  final String costValue;
  final String costCurrency;
  final String vendor;
  final Uint8List? photoBytes;
  final String? photoFileName;
  final UsageIntervalUnit? usageUnit;
  final Device? device;
  final Device? usageOwner;
  final String? errorMessage;

  bool get isSaving => status == DeviceLogStatus.saving;

  bool get hasPhoto => photoBytes != null && photoBytes!.isNotEmpty;

  DeviceLogFormState copyWith({
    DeviceLogStatus? status,
    DeviceLogKind? kind,
    String? notes,
    DateTime? date,
    String? usageValue,
    String? costValue,
    String? costCurrency,
    String? vendor,
    Uint8List? photoBytes,
    String? photoFileName,
    UsageIntervalUnit? usageUnit,
    Device? device,
    Device? usageOwner,
    String? errorMessage,
    bool clearError = false,
    bool clearPhoto = false,
  }) {
    return DeviceLogFormState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      usageValue: usageValue ?? this.usageValue,
      costValue: costValue ?? this.costValue,
      costCurrency: costCurrency ?? this.costCurrency,
      vendor: vendor ?? this.vendor,
      photoBytes: clearPhoto ? null : (photoBytes ?? this.photoBytes),
      photoFileName: clearPhoto ? null : (photoFileName ?? this.photoFileName),
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
    costValue,
    costCurrency,
    vendor,
    photoBytes,
    photoFileName,
    usageUnit,
    device,
    usageOwner,
    errorMessage,
  ];
}
