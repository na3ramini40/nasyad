part of 'archived_devices_bloc.dart';

sealed class ArchivedDevicesState extends Equatable {
  const ArchivedDevicesState();

  @override
  List<Object?> get props => [];
}

final class ArchivedDevicesInitial extends ArchivedDevicesState {
  const ArchivedDevicesInitial();
}

final class ArchivedDevicesLoading extends ArchivedDevicesState {
  const ArchivedDevicesLoading();
}

final class ArchivedDevicesLoaded extends ArchivedDevicesState {
  const ArchivedDevicesLoaded(this.devices);

  final List<Device> devices;

  @override
  List<Object?> get props => [devices];
}

final class ArchivedDevicesRestoreFailed extends ArchivedDevicesState {
  const ArchivedDevicesRestoreFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ArchivedDevicesError extends ArchivedDevicesState {
  const ArchivedDevicesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
