import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/preferences/reminder_snooze_store.dart';
import 'package:nasyad/core/preferences/soon_window_preference_store.dart';
import 'package:nasyad/domain/entities/home_reminder_filter.dart';
import 'package:nasyad/domain/entities/maintenance_status.dart';
import 'package:nasyad/domain/usecases/birthday/watch_birthdays_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summaries_usecase.dart';
import 'package:nasyad/domain/usecases/home/snooze_home_reminder_usecase.dart';
import 'package:nasyad/domain/usecases/home/watch_home_reminders_usecase.dart';
import 'package:nasyad/presentation/home/bloc/home_bloc.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';
import 'birthday_list_bloc_test.dart';

void main() {
  late FakeDeviceRepository deviceRepository;
  late FakeBirthdayRepository birthdayRepository;
  late ReminderSnoozeStore snoozeStore;
  late SoonWindowPreferenceStore soonWindowStore;
  late HomeBloc bloc;

  setUp(() {
    deviceRepository = FakeDeviceRepository();
    birthdayRepository = FakeBirthdayRepository();
    snoozeStore = ReminderSnoozeStore.memory();
    soonWindowStore = SoonWindowPreferenceStore.memory();
    bloc = HomeBloc(
      WatchHomeRemindersUsecase(
        WatchDeviceSummariesUsecase(deviceRepository),
        WatchBirthdaysUsecase(birthdayRepository),
        snoozeStore,
        soonWindowStore,
      ),
      SnoozeHomeReminderUsecase(snoozeStore),
    );
  });

  tearDown(() async {
    await bloc.close();
    await deviceRepository.dispose();
    await birthdayRepository.dispose();
    snoozeStore.dispose();
    soonWindowStore.dispose();
  });

  test('starts as HomeInitial', () {
    expect(bloc.state, const HomeInitial());
  });

  test('emits loading then loaded on start', () async {
    expectLater(
      bloc.stream,
      emitsInOrder([
        const HomeLoading(),
        isA<HomeLoaded>(),
        isA<HomeLoaded>().having(
          (s) => s.allReminders,
          'allReminders',
          hasLength(1),
        ),
      ]),
    );

    bloc.add(const HomeStarted());
    await Future<void>.delayed(Duration.zero);
    deviceRepository.emitSummaries([
      sampleSummary(status: MaintenanceStatus.due),
    ]);
    birthdayRepository.emit();
  });

  test('emits error when watch fails', () async {
    expectLater(bloc.stream, emitsThrough(isA<HomeError>()));

    bloc.add(const HomeStarted());
    await Future<void>.delayed(Duration.zero);
    deviceRepository.emitError(Exception('boom'));
  });

  test(
    'filter change updates visible reminders without resubscribing',
    () async {
      bloc.add(const HomeStarted());
      await Future<void>.delayed(Duration.zero);
      deviceRepository.emitSummaries([
        sampleSummary(status: MaintenanceStatus.due),
        sampleSummary(
          device: sampleDevice(id: 'device-2', name: 'Car'),
          status: MaintenanceStatus.soon,
        ),
      ]);
      birthdayRepository.emit();
      await Future<void>.delayed(Duration.zero);

      bloc.add(const HomeFilterChanged(HomeReminderFilter.devices));
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state as HomeLoaded;
      expect(state.filter, HomeReminderFilter.devices);
      expect(state.visibleReminders, hasLength(2));
    },
  );

  test('snooze removes reminder from loaded list', () async {
    bloc.add(const HomeStarted());
    await Future<void>.delayed(Duration.zero);
    deviceRepository.emitSummaries([
      sampleSummary(
        device: sampleDevice(id: 'device-1'),
        status: MaintenanceStatus.due,
      ),
    ]);
    birthdayRepository.emit();
    await Future<void>.delayed(Duration.zero);

    bloc.add(const HomeReminderSnoozed(reminderId: 'device-device-1', days: 3));
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as HomeLoaded;
    expect(state.allReminders, isEmpty);
  });
}
