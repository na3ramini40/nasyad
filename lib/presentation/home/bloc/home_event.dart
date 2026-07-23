part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class _HomeSummariesUpdated extends HomeEvent {
  const _HomeSummariesUpdated(this.summaries);

  final List<DeviceSummary> summaries;

  @override
  List<Object?> get props => [summaries];
}

final class _HomeWatchFailed extends HomeEvent {
  const _HomeWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
