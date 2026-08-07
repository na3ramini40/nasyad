part of 'device_detail_bloc.dart';

sealed class DeviceDetailState extends Equatable {
  const DeviceDetailState();

  @override
  List<Object?> get props => [];
}

final class DeviceDetailLoading extends DeviceDetailState {
  const DeviceDetailLoading();
}

final class DeviceDetailLoaded extends DeviceDetailState {
  const DeviceDetailLoaded({required this.summary, required this.logs});

  final DeviceSummary summary;
  final List<DeviceLog> logs;

  @override
  List<Object?> get props => [summary, logs];
}

final class DeviceDetailNotFound extends DeviceDetailState {
  const DeviceDetailNotFound();
}

final class DeviceDetailArchived extends DeviceDetailState {
  const DeviceDetailArchived();
}

final class DeviceDetailError extends DeviceDetailState {
  const DeviceDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
