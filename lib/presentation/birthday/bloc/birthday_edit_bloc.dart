import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/services/month_day.dart';
import 'package:nasyad/domain/usecases/birthday/create_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/delete_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/get_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/update_birthday_usecase.dart';

part 'birthday_edit_event.dart';
part 'birthday_edit_state.dart';

class BirthdayEditBloc extends Bloc<BirthdayEditEvent, BirthdayEditState> {
  BirthdayEditBloc({
    this.birthdayId,
    required GetBirthdayUsecase getBirthday,
    required CreateBirthdayUsecase createBirthday,
    required UpdateBirthdayUsecase updateBirthday,
    required DeleteBirthdayUsecase deleteBirthday,
    required CalendarSystem preferredCalendar,
  }) : _getBirthday = getBirthday,
       _createBirthday = createBirthday,
       _updateBirthday = updateBirthday,
       _deleteBirthday = deleteBirthday,
       super(
         BirthdayEditState(
           isEdit: birthdayId != null,
           calendarSystem: preferredCalendar,
         ),
       ) {
    on<BirthdayEditStarted>(_onStarted);
    on<BirthdayEditNameChanged>(_onNameChanged);
    on<BirthdayEditMonthDayChanged>(_onMonthDayChanged);
    on<BirthdayEditSaveRequested>(_onSave);
    on<BirthdayEditDeleteRequested>(_onDelete);
  }

  final String? birthdayId;
  final GetBirthdayUsecase _getBirthday;
  final CreateBirthdayUsecase _createBirthday;
  final UpdateBirthdayUsecase _updateBirthday;
  final DeleteBirthdayUsecase _deleteBirthday;
  Birthday? _existing;

  Future<void> _onStarted(
    BirthdayEditStarted event,
    Emitter<BirthdayEditState> emit,
  ) async {
    if (birthdayId == null) {
      emit(state.copyWith(status: BirthdayEditStatus.ready));
      return;
    }

    emit(state.copyWith(status: BirthdayEditStatus.loading));
    try {
      final birthday = await _getBirthday(birthdayId!);
      _existing = birthday;
      if (birthday == null) {
        emit(
          state.copyWith(
            status: BirthdayEditStatus.failure,
            errorMessage: 'Birthday not found',
          ),
        );
        return;
      }

      final displayed = MonthDay.convert(
        month: birthday.birthMonth,
        day: birthday.birthDay,
        from: birthday.calendarSystem,
        to: event.preferredCalendar,
      );

      emit(
        state.copyWith(
          status: BirthdayEditStatus.ready,
          name: birthday.name,
          birthMonth: displayed.month,
          birthDay: displayed.day,
          calendarSystem: event.preferredCalendar,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BirthdayEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onNameChanged(
    BirthdayEditNameChanged event,
    Emitter<BirthdayEditState> emit,
  ) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  void _onMonthDayChanged(
    BirthdayEditMonthDayChanged event,
    Emitter<BirthdayEditState> emit,
  ) {
    emit(
      state.copyWith(
        birthMonth: event.month,
        birthDay: event.day,
        calendarSystem: event.calendarSystem,
        clearError: true,
      ),
    );
  }

  Future<void> _onSave(
    BirthdayEditSaveRequested event,
    Emitter<BirthdayEditState> emit,
  ) async {
    if (state.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: BirthdayEditStatus.ready,
          errorMessage: event.nameRequiredMessage,
        ),
      );
      return;
    }
    if (state.birthMonth == null || state.birthDay == null) {
      emit(
        state.copyWith(
          status: BirthdayEditStatus.ready,
          errorMessage: event.monthDayRequiredMessage,
        ),
      );
      return;
    }

    emit(state.copyWith(status: BirthdayEditStatus.saving, clearError: true));
    final now = DateTime.now();
    try {
      if (_existing == null) {
        await _createBirthday(
          Birthday(
            id: IdGenerator.newId(),
            name: state.name,
            birthMonth: state.birthMonth!,
            birthDay: state.birthDay!,
            calendarSystem: state.calendarSystem,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await _updateBirthday(
          _existing!.copyWith(
            name: state.name,
            birthMonth: state.birthMonth,
            birthDay: state.birthDay,
            calendarSystem: state.calendarSystem,
            updatedAt: now,
          ),
        );
      }
      emit(state.copyWith(status: BirthdayEditStatus.saved));
    } catch (error) {
      emit(
        state.copyWith(
          status: BirthdayEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDelete(
    BirthdayEditDeleteRequested event,
    Emitter<BirthdayEditState> emit,
  ) async {
    if (birthdayId == null) return;
    emit(state.copyWith(status: BirthdayEditStatus.saving, clearError: true));
    try {
      await _deleteBirthday(birthdayId!);
      emit(state.copyWith(status: BirthdayEditStatus.deleted));
    } catch (error) {
      emit(
        state.copyWith(
          status: BirthdayEditStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
