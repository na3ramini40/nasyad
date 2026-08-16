import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_template.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/services/schedule_template_catalog.dart';
import 'package:nasyad/domain/usecases/device/create_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/delete_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/update_device_usecase.dart';
import 'package:nasyad/presentation/device/bloc/device_edit_bloc.dart';

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

Future<void> _startBloc(DeviceEditBloc bloc) async {
  bloc.add(const DeviceEditStarted());
  await bloc.stream.firstWhere(
    (state) => state.status == DeviceEditStatus.ready,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDeviceRepository repository;

  setUp(() {
    ScheduleTemplateCatalog.resetCacheForTesting();
    repository = FakeDeviceRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  test('create flow becomes ready and saves device', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    await _startBloc(bloc);
    expect(bloc.state.templates, isNotEmpty);

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

    await _startBloc(bloc);
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

  test('template applied updates schedule fields', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    await _startBloc(bloc);
    bloc.add(
      DeviceEditTemplateApplied(
        const ScheduleTemplate(
          id: 'hours_500',
          labelEn: 'Every 500 hours',
          labelFa: 'هر ۵۰۰ ساعت',
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
            .having((s) => s.intervalUnit, 'unit', 'hours')
            .having((s) => s.appliedTemplateId, 'template', 'hours_500'),
      ),
    );
  });

  test('fixed-date template sets due date', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    await _startBloc(bloc);
    bloc.add(
      DeviceEditTemplateApplied(
        const ScheduleTemplate(
          id: 'annual',
          labelEn: 'Annual',
          labelFa: 'سالانه',
          scheduleType: ScheduleType.fixedDate,
          intervalValue: 12,
          intervalUnit: 'months',
        ),
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceEditState>()
            .having((s) => s.scheduleType, 'type', ScheduleType.fixedDate)
            .having((s) => s.fixedDueAt, 'due', isNotNull),
      ),
    );
  });

  test('saves container with no schedule', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    await _startBloc(bloc);
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

  test('creates usage-interval root with explicit usage unit', () async {
    final bloc = _build(repository);
    addTearDown(bloc.close);

    await _startBloc(bloc);
    bloc.add(const DeviceEditNameChanged('Bike'));
    bloc.add(const DeviceEditScheduleTypeChanged(ScheduleType.usageInterval));
    bloc.add(const DeviceEditIntervalUnitChanged('km'));
    bloc.add(const DeviceEditIntervalChanged('500'));
    bloc.add(const DeviceEditUsageUnitChanged(UsageIntervalUnit.km));
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
    expect(repository.devices.single.scheduleType, ScheduleType.usageInterval);
    expect(repository.devices.single.usageUnit, UsageIntervalUnit.km);
    expect(repository.devices.single.intervalValue, 500);
  });

  test(
    'create child keeps parentId and inherits parent usage by default',
    () async {
      final bloc = _build(repository, parentId: 'car');
      addTearDown(bloc.close);

      await _startBloc(bloc);
      expect(bloc.state.parentId, 'car');
      expect(bloc.state.useParentUsage, isTrue);

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
      expect(repository.devices.single.usageUnit, isNull);
      expect(repository.lastInitialElapsed, 300);
    },
  );
}
