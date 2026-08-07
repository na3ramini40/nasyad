part of 'birthday_edit_bloc.dart';

sealed class BirthdayEditEvent extends Equatable {
  const BirthdayEditEvent();

  @override
  List<Object?> get props => [];
}

final class BirthdayEditStarted extends BirthdayEditEvent {
  const BirthdayEditStarted({required this.preferredCalendar});

  final CalendarSystem preferredCalendar;

  @override
  List<Object?> get props => [preferredCalendar];
}

final class BirthdayEditNameChanged extends BirthdayEditEvent {
  const BirthdayEditNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class BirthdayEditMonthDayChanged extends BirthdayEditEvent {
  const BirthdayEditMonthDayChanged({
    required this.month,
    required this.day,
    required this.calendarSystem,
  });

  final int month;
  final int day;
  final CalendarSystem calendarSystem;

  @override
  List<Object?> get props => [month, day, calendarSystem];
}

final class BirthdayEditSaveRequested extends BirthdayEditEvent {
  const BirthdayEditSaveRequested({
    required this.nameRequiredMessage,
    required this.monthDayRequiredMessage,
  });

  final String nameRequiredMessage;
  final String monthDayRequiredMessage;

  @override
  List<Object?> get props => [nameRequiredMessage, monthDayRequiredMessage];
}

final class BirthdayEditDeleteRequested extends BirthdayEditEvent {
  const BirthdayEditDeleteRequested();
}
