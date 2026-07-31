import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/presentation/device/bloc/device_edit_bloc.dart';
import 'package:nasyad/presentation/device/schedule_presets.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

DeviceEditBloc _build(
  FakeDeviceRepository repo, {
  String? deviceId,
  String? parentId,
}) {
  return DeviceEditBloc(
    deviceId: deviceId,
    parentId: parentId,
    getDevice: GetDeviceUsecase(repo),
    createDevice: CreateDeviceUsecase(repo),
    updateDevice: UpdateDeviceUsecase(repo),
    deleteDevice: DeleteDeviceUsecase(repo),
  );
}

void main() {
  late FakeDeviceRepository repository;

  setUp(() {
    repository = FakeDeviceRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  test('create flow becomes ready and saves device', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    bloc.add(const DeviceEditStarted());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.status, DeviceEditStatus.ready);

    bloc.add(const DeviceEditNameChanged('Compressor'));
    bloc.add(
      const DeviceEditScheduleTypeChanged(ScheduleType.calendarInterval),
    );
    bloc.add(const DeviceEditIntervalUnitChanged('months'));
    bloc.add(const DeviceEditIntervalChanged('3'));
    bloc.add(
      const DeviceEditSaveRequested(
        nameRequiredMessage: 'name',
        selectScheduleTypeMessage: 'schedule',
        selectIntervalUnitMessage: 'unit',
        intervalAmountRequiredMessage: 'amount',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>().having(
          (s) => s.status,
          'status',
          DeviceEditStatus.saved,
        ),
      ),
    );
    expect(repository.createCalls, 1);
  });

  test('save fails validation when name empty', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    bloc.add(const DeviceEditStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(
      const DeviceEditSaveRequested(
        nameRequiredMessage: 'name required',
        selectScheduleTypeMessage: 'schedule',
        selectIntervalUnitMessage: 'unit',
        intervalAmountRequiredMessage: 'amount',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>()
            .having((s) => s.status, 'status', DeviceEditStatus.failure)
            .having((s) => s.errorMessage, 'error', 'name required'),
      ),
    );
  });

  test('edit flow loads existing device and deletes', () async {
    repository.devices.add(sampleDevice());

    final bloc = _build(repository, deviceId: 'device-1');
    addTearDown(bloc.close);

    bloc.add(const DeviceEditStarted());
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>()
            .having((s) => s.status, 'status', DeviceEditStatus.ready)
            .having((s) => s.name, 'name', 'Pump')
            .having((s) => s.intervalValue, 'interval', '3'),
      ),
    );

    bloc.add(const DeviceEditDeleteRequested());
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>().having(
          (s) => s.status,
          'status',
          DeviceEditStatus.deleted,
        ),
      ),
    );
  });

  test('suggestion applied updates schedule fields', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    bloc.add(const DeviceEditStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(
      DeviceEditSuggestionApplied(
        const ScheduleSuggestion(
          label: 'Every 500 hours',
          scheduleType: ScheduleType.usageInterval,
          intervalValue: 500,
          intervalUnit: 'hours',
        ),
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>()
            .having((s) => s.scheduleType, 'type', ScheduleType.usageInterval)
            .having((s) => s.intervalValue, 'value', '500')
            .having((s) => s.intervalUnit, 'unit', 'hours'),
      ),
    );
  });

  test('saves container with no schedule', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    bloc.add(const DeviceEditStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const DeviceEditNameChanged('Car'));
    bloc.add(const DeviceEditScheduleEnabledChanged(false));
    bloc.add(
      const DeviceEditSaveRequested(
        nameRequiredMessage: 'name',
        selectScheduleTypeMessage: 'schedule',
        selectIntervalUnitMessage: 'unit',
        intervalAmountRequiredMessage: 'amount',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>().having(
          (s) => s.status,
          'status',
          DeviceEditStatus.saved,
        ),
      ),
    );
    expect(repository.devices.single.hasSchedule, isFalse);
    expect(repository.devices.single.name, 'Car');
  });

  test('create child keeps parentId and initialElapsed', () async {
    final bloc = _build(repository, parentId: 'car');
    addTearDown(bloc.close);

    bloc.add(const DeviceEditStarted());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.parentId, 'car');

    bloc.add(const DeviceEditNameChanged('Oil'));
    bloc.add(const DeviceEditScheduleTypeChanged(ScheduleType.usageInterval));
    bloc.add(const DeviceEditIntervalUnitChanged('km'));
    bloc.add(const DeviceEditIntervalChanged('1000'));
    bloc.add(const DeviceEditInitialElapsedChanged('300'));
    bloc.add(
      const DeviceEditSaveRequested(
        nameRequiredMessage: 'name',
        selectScheduleTypeMessage: 'schedule',
        selectIntervalUnitMessage: 'unit',
        intervalAmountRequiredMessage: 'amount',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>().having(
          (s) => s.status,
          'status',
          DeviceEditStatus.saved,
        ),
      ),
    );
    expect(repository.devices.single.parentId, 'car');
    expect(repository.lastInitialElapsed, 300);
  });
}
