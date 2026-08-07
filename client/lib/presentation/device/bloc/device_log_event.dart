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

final class DeviceLogCostValueChanged extends DeviceLogEvent {
  const DeviceLogCostValueChanged(this.costValue);

  final String costValue;

  @override
  List<Object?> get props => [costValue];
}

final class DeviceLogCostCurrencyChanged extends DeviceLogEvent {
  const DeviceLogCostCurrencyChanged(this.costCurrency);

  final String costCurrency;

  @override
  List<Object?> get props => [costCurrency];
}

final class DeviceLogVendorChanged extends DeviceLogEvent {
  const DeviceLogVendorChanged(this.vendor);

  final String vendor;

  @override
  List<Object?> get props => [vendor];
}

final class DeviceLogPhotoSelected extends DeviceLogEvent {
  const DeviceLogPhotoSelected(this.bytes, this.fileName);

  final Uint8List bytes;
  final String fileName;

  @override
  List<Object?> get props => [bytes, fileName];
}

final class DeviceLogPhotoCleared extends DeviceLogEvent {
  const DeviceLogPhotoCleared();
}

final class DeviceLogSubmitRequested extends DeviceLogEvent {
  const DeviceLogSubmitRequested({
    required this.usageReadingRequiredMessage,
    required this.invalidCostMessage,
  });

  final String usageReadingRequiredMessage;
  final String invalidCostMessage;

  @override
  List<Object?> get props => [usageReadingRequiredMessage, invalidCostMessage];
}
