part of 'birthday_list_bloc.dart';

sealed class BirthdayListEvent extends Equatable {
  const BirthdayListEvent();

  @override
  List<Object?> get props => [];
}

final class BirthdayListStarted extends BirthdayListEvent {
  const BirthdayListStarted();
}

final class BirthdayListDeleteRequested extends BirthdayListEvent {
  const BirthdayListDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class _BirthdayListUpdated extends BirthdayListEvent {
  const _BirthdayListUpdated(this.birthdays);

  final List<Birthday> birthdays;

  @override
  List<Object?> get props => [birthdays];
}

final class _BirthdayListWatchFailed extends BirthdayListEvent {
  const _BirthdayListWatchFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
