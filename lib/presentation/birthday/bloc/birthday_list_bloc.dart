import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/usecases/birthday/delete_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';

part 'birthday_list_event.dart';
part 'birthday_list_state.dart';

class BirthdayListBloc extends Bloc<BirthdayListEvent, BirthdayListState> {
  BirthdayListBloc({
    required WatchBirthdaysUsecase watchBirthdays,
    required DeleteBirthdayUsecase deleteBirthday,
  }) : _watchBirthdays = watchBirthdays,
       _deleteBirthday = deleteBirthday,
       super(const BirthdayListInitial()) {
    on<BirthdayListStarted>(_onStarted);
    on<_BirthdayListUpdated>(_onUpdated);
    on<_BirthdayListWatchFailed>(_onWatchFailed);
    on<BirthdayListDeleteRequested>(_onDelete);
  }

  final WatchBirthdaysUsecase _watchBirthdays;
  final DeleteBirthdayUsecase _deleteBirthday;
  StreamSubscription<List<Birthday>>? _subscription;

  Future<void> _onStarted(
    BirthdayListStarted event,
    Emitter<BirthdayListState> emit,
  ) async {
    emit(const BirthdayListLoading());
    await _subscription?.cancel();
    _subscription = _watchBirthdays().listen(
      (items) => add(_BirthdayListUpdated(items)),
      onError: (Object error, StackTrace _) =>
          add(_BirthdayListWatchFailed(error)),
    );
  }

  void _onUpdated(_BirthdayListUpdated event, Emitter<BirthdayListState> emit) {
    emit(BirthdayListLoaded(event.birthdays));
  }

  void _onWatchFailed(
    _BirthdayListWatchFailed event,
    Emitter<BirthdayListState> emit,
  ) {
    emit(BirthdayListError(event.error.toString()));
  }

  Future<void> _onDelete(
    BirthdayListDeleteRequested event,
    Emitter<BirthdayListState> emit,
  ) async {
    try {
      await _deleteBirthday(event.id);
    } catch (error) {
      emit(BirthdayListError(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
