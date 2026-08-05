part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeFilterChanged extends HomeEvent {
  const HomeFilterChanged(this.filter);

  final HomeReminderFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class _HomeRemindersUpdated extends HomeEvent {
  const _HomeRemindersUpdated(this.reminders);

  final List<HomeReminder> reminders;

  @override
  List<Object?> get props => [reminders];
}

final class _HomeWatchFailed extends HomeEvent {
  const _HomeWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
