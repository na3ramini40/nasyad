import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/usecases/birthday/create_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/delete_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/get_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/update_birthday_usecase.dart';
import 'package:nasyad/presentation/birthday/bloc/birthday_edit_bloc.dart';

import '../helpers/fake_repositories.dart';

Birthday _birthdaySample({String id = 'b1', String name = 'Ada'}) {
  final now = DateTime(2026, 1, 1);
  return Birthday(
    id: id,
    name: name,
    birthMonth: 1,
    birthDay: 15,
    calendarSystem: CalendarSystem.gregorian,
    createdAt: now,
    updatedAt: now,
  );
}

const _saveMessages = BirthdayEditSaveRequested(
  nameRequiredMessage: 'name required',
  monthDayRequiredMessage: 'date required',
);

BirthdayEditBloc _build(
  FakeBirthdayRepository repo, {
  String? birthdayId,
  CalendarSystem preferred = CalendarSystem.gregorian,
}) {
  return BirthdayEditBloc(
    birthdayId: birthdayId,
    getBirthday: GetBirthdayUsecase(repo),
    createBirthday: CreateBirthdayUsecase(repo),
    updateBirthday: UpdateBirthdayUsecase(repo),
    deleteBirthday: DeleteBirthdayUsecase(repo),
    preferredCalendar: preferred,
  );
}

void main() {
  late FakeBirthdayRepository repository;

  setUp(() {
    repository = FakeBirthdayRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('adding birthdays', () {
    test('creates gregorian birthday with name and month/day', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(
        const BirthdayEditStarted(preferredCalendar: CalendarSystem.gregorian),
      );
      await Future<void>.delayed(Duration.zero);

      bloc.add(const BirthdayEditNameChanged('Sara'));
      bloc.add(
        const BirthdayEditMonthDayChanged(
          month: 3,
          day: 21,
          calendarSystem: CalendarSystem.gregorian,
        ),
      );
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>().having(
            (s) => s.status,
            'status',
            BirthdayEditStatus.saved,
          ),
        ),
      );
      expect(repository.items, hasLength(1));
      expect(repository.items.first.name, 'Sara');
      expect(repository.items.first.birthMonth, 3);
      expect(repository.items.first.birthDay, 21);
      expect(repository.items.first.calendarSystem, CalendarSystem.gregorian);
    });

    test('creates persian calendar birthday', () async {
      final bloc = _build(repository, preferred: CalendarSystem.persian);
      addTearDown(bloc.close);

      bloc.add(
        const BirthdayEditStarted(preferredCalendar: CalendarSystem.persian),
      );
      await Future<void>.delayed(Duration.zero);

      bloc.add(const BirthdayEditNameChanged('Reza'));
      bloc.add(
        const BirthdayEditMonthDayChanged(
          month: 1,
          day: 1,
          calendarSystem: CalendarSystem.persian,
        ),
      );
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>().having(
            (s) => s.status,
            'status',
            BirthdayEditStatus.saved,
          ),
        ),
      );
      expect(repository.items.single.calendarSystem, CalendarSystem.persian);
    });

    test('rejects save when name empty', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(
        const BirthdayEditStarted(preferredCalendar: CalendarSystem.gregorian),
      );
      await Future<void>.delayed(Duration.zero);
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>()
              .having((s) => s.status, 'status', BirthdayEditStatus.ready)
              .having((s) => s.errorMessage, 'error', 'name required'),
        ),
      );
      expect(repository.items, isEmpty);
    });

    test('rejects save when month/day missing', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(
        const BirthdayEditStarted(preferredCalendar: CalendarSystem.gregorian),
      );
      await Future<void>.delayed(Duration.zero);
      bloc.add(const BirthdayEditNameChanged('Sara'));
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>()
              .having((s) => s.status, 'status', BirthdayEditStatus.ready)
              .having((s) => s.errorMessage, 'error', 'date required'),
        ),
      );
    });
  });

  group('editing birthdays', () {
    test('loads existing birthday and updates name', () async {
      repository.items.add(_birthdaySample(id: 'b1', name: 'Ada'));

      final bloc = _build(repository, birthdayId: 'b1');
      addTearDown(bloc.close);

      bloc.add(
        const BirthdayEditStarted(preferredCalendar: CalendarSystem.gregorian),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>()
              .having((s) => s.status, 'status', BirthdayEditStatus.ready)
              .having((s) => s.name, 'name', 'Ada'),
        ),
      );

      bloc.add(const BirthdayEditNameChanged('Ada Updated'));
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>().having(
            (s) => s.status,
            'status',
            BirthdayEditStatus.saved,
          ),
        ),
      );
      expect(repository.items.single.name, 'Ada Updated');
    });

    test('deletes existing birthday', () async {
      repository.items.add(_birthdaySample(id: 'b1'));

      final bloc = _build(repository, birthdayId: 'b1');
      addTearDown(bloc.close);

      bloc.add(
        const BirthdayEditStarted(preferredCalendar: CalendarSystem.gregorian),
      );
      await Future<void>.delayed(Duration.zero);
      bloc.add(const BirthdayEditDeleteRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<BirthdayEditState>().having(
            (s) => s.status,
            'status',
            BirthdayEditStatus.deleted,
          ),
        ),
      );
      expect(repository.items, isEmpty);
    });
  });
}
