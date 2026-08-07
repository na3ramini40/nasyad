part of 'device_detail_bloc.dart';

sealed class DeviceDetailEvent extends Equatable {
  const DeviceDetailEvent();

  @override
  List<Object?> get props => [];
}

final class DeviceDetailStarted extends DeviceDetailEvent {
  const DeviceDetailStarted();
}

final class DeviceDetailArchiveRequested extends DeviceDetailEvent {
  const DeviceDetailArchiveRequested();
}

final class _DeviceDetailSummaryUpdated extends DeviceDetailEvent {
  const _DeviceDetailSummaryUpdated(this.summary);

  final DeviceSummary? summary;

  @override
  List<Object?> get props => [summary];
}

final class _DeviceDetailLogsUpdated extends DeviceDetailEvent {
  const _DeviceDetailLogsUpdated(this.logs);

  final List<DeviceLog> logs;

  @override
  List<Object?> get props => [logs];
}

final class _DeviceDetailWatchFailed extends DeviceDetailEvent {
  const _DeviceDetailWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
