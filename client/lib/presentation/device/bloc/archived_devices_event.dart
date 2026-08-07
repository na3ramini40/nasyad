part of 'archived_devices_bloc.dart';

sealed class ArchivedDevicesEvent extends Equatable {
  const ArchivedDevicesEvent();

  @override
  List<Object?> get props => [];
}

final class ArchivedDevicesStarted extends ArchivedDevicesEvent {
  const ArchivedDevicesStarted();
}

final class ArchivedDevicesRestoreRequested extends ArchivedDevicesEvent {
  const ArchivedDevicesRestoreRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class _ArchivedDevicesUpdated extends ArchivedDevicesEvent {
  const _ArchivedDevicesUpdated(this.devices);

  final List<Device> devices;

  @override
  List<Object?> get props => [devices];
}

final class _ArchivedDevicesWatchFailed extends ArchivedDevicesEvent {
  const _ArchivedDevicesWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
