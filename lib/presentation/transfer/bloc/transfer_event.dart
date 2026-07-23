part of 'transfer_bloc.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

final class TransferStarted extends TransferEvent {
  const TransferStarted();
}

final class TransferScopeChanged extends TransferEvent {
  const TransferScopeChanged(this.scope);

  final ExportScopeKind scope;

  @override
  List<Object?> get props => [scope];
}

final class TransferFormatChanged extends TransferEvent {
  const TransferFormatChanged(this.format);

  final ExportFormat format;

  @override
  List<Object?> get props => [format];
}

final class TransferDeviceToggled extends TransferEvent {
  const TransferDeviceToggled(this.deviceId);

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

final class TransferShareRequested extends TransferEvent {
  const TransferShareRequested({required this.noDevicesMessage});

  final String noDevicesMessage;

  @override
  List<Object?> get props => [noDevicesMessage];
}

final class TransferSaveRequested extends TransferEvent {
  const TransferSaveRequested({required this.noDevicesMessage});

  final String noDevicesMessage;

  @override
  List<Object?> get props => [noDevicesMessage];
}

final class TransferPickImportRequested extends TransferEvent {
  const TransferPickImportRequested({required this.invalidFileMessage});

  final String invalidFileMessage;

  @override
  List<Object?> get props => [invalidFileMessage];
}

final class TransferImportConfirmed extends TransferEvent {
  const TransferImportConfirmed({required this.invalidFileMessage});

  final String invalidFileMessage;

  @override
  List<Object?> get props => [invalidFileMessage];
}

final class TransferFeedbackCleared extends TransferEvent {
  const TransferFeedbackCleared();
}
