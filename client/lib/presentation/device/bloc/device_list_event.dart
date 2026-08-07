part of 'device_list_bloc.dart';

sealed class DeviceListEvent extends Equatable {
  const DeviceListEvent();

  @override
  List<Object?> get props => [];
}

final class DeviceListStarted extends DeviceListEvent {
  const DeviceListStarted();
}

final class _DeviceListSummariesUpdated extends DeviceListEvent {
  const _DeviceListSummariesUpdated(this.summaries);

  final List<DeviceSummary> summaries;

  @override
  List<Object?> get props => [summaries];
}

final class _DeviceListWatchFailed extends DeviceListEvent {
  const _DeviceListWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
