part of 'birthday_edit_bloc.dart';

enum BirthdayEditStatus { loading, ready, saving, saved, deleted, failure }

final class BirthdayEditState extends Equatable {
  const BirthdayEditState({
    this.status = BirthdayEditStatus.loading,
    this.isEdit = false,
    this.name = '',
    this.birthMonth,
    this.birthDay,
    this.calendarSystem = CalendarSystem.gregorian,
    this.errorMessage,
  });

  final BirthdayEditStatus status;
  final bool isEdit;
  final String name;
  final int? birthMonth;
  final int? birthDay;
  final CalendarSystem calendarSystem;
  final String? errorMessage;

  BirthdayEditState copyWith({
    BirthdayEditStatus? status,
    bool? isEdit,
    String? name,
    int? birthMonth,
    int? birthDay,
    CalendarSystem? calendarSystem,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BirthdayEditState(
      status: status ?? this.status,
      isEdit: isEdit ?? this.isEdit,
      name: name ?? this.name,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      calendarSystem: calendarSystem ?? this.calendarSystem,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    isEdit,
    name,
    birthMonth,
    birthDay,
    calendarSystem,
    errorMessage,
  ];
}
