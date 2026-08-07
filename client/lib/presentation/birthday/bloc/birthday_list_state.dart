part of 'birthday_list_bloc.dart';

sealed class BirthdayListState extends Equatable {
  const BirthdayListState();

  @override
  List<Object?> get props => [];
}

final class BirthdayListInitial extends BirthdayListState {
  const BirthdayListInitial();
}

final class BirthdayListLoading extends BirthdayListState {
  const BirthdayListLoading();
}

final class BirthdayListLoaded extends BirthdayListState {
  const BirthdayListLoaded(this.birthdays);

  final List<Birthday> birthdays;

  @override
  List<Object?> get props => [birthdays];
}

final class BirthdayListError extends BirthdayListState {
  const BirthdayListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
