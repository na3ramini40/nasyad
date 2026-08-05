part of 'device_list_bloc.dart';

sealed class DeviceListState extends Equatable {
  const DeviceListState();

  @override
  List<Object?> get props => [];
}

final class DeviceListInitial extends DeviceListState {
  const DeviceListInitial();
}

final class DeviceListLoading extends DeviceListState {
  const DeviceListLoading();
}

final class DeviceListLoaded extends DeviceListState {
  const DeviceListLoaded(this.summaries);

  final List<DeviceSummary> summaries;

  @override
  List<Object?> get props => [summaries];
}

final class DeviceListError extends DeviceListState {
  const DeviceListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
