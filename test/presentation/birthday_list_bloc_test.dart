import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/usecases/birthday/create_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/delete_birthday_usecase.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/presentation/birthday/bloc/birthday_list_bloc.dart';

class FakeBirthdayRepository implements BirthdayRepository {
  final List<Birthday> items = [];
  final StreamController<List<Birthday>> controller =
      StreamController<List<Birthday>>.broadcast();

  void emit() => controller.add(List.unmodifiable(items));

  @override
  Stream<List<Birthday>> watchBirthdays() => controller.stream;

  @override
  Future<Birthday?> getBirthday(String id) async {
    return items.where((b) => b.id == id).firstOrNull;
  }

  @override
  Future<void> createBirthday(Birthday birthday) async {
    items.add(birthday);
    emit();
  }

  @override
  Future<void> updateBirthday(Birthday birthday) async {
    final index = items.indexWhere((b) => b.id == birthday.id);
    if (index >= 0) items[index] = birthday;
    emit();
  }

  @override
  Future<void> deleteBirthday(String id) async {
    items.removeWhere((b) => b.id == id);
    emit();
  }

  Future<void> dispose() => controller.close();
}

Birthday _sample({String id = 'b1', String name = 'Ada'}) {
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

void main() {
  group('CreateBirthdayUsecase', () {
    test('rejects empty name', () {
      final usecase = CreateBirthdayUsecase(FakeBirthdayRepository());
      expect(() => usecase(_sample(name: '  ')), throwsArgumentError);
    });
  });

  group('BirthdayListBloc', () {
    late FakeBirthdayRepository repository;
    late BirthdayListBloc bloc;

    setUp(() {
      repository = FakeBirthdayRepository();
      bloc = BirthdayListBloc(
        watchBirthdays: WatchBirthdaysUsecase(repository),
        deleteBirthday: DeleteBirthdayUsecase(repository),
      );
    });

    tearDown(() async {
      await bloc.close();
      await repository.dispose();
    });

    test('loads birthdays from watch', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          const BirthdayListLoading(),
          isA<BirthdayListLoaded>().having(
            (s) => s.birthdays,
            'birthdays',
            hasLength(1),
          ),
        ]),
      );

      bloc.add(const BirthdayListStarted());
      await Future<void>.delayed(Duration.zero);
      repository.items.add(_sample());
      repository.emit();
    });
  });
}
