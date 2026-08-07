import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/usecases/device/get_device_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';
import 'package:nasyad/presentation/device/bloc/device_log_bloc.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository devices;
  late FakeDeviceLogRepository logs;
  late DeviceLogBloc bloc;

  setUp(() {
    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    devices.devices.add(
      sampleDevice(
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 1000,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      ),
    );
    bloc = DeviceLogBloc(
      deviceId: 'device-1',
      createDeviceLog: CreateDeviceLogUsecase(logs),
      getDevice: GetDeviceUsecase(devices),
    );
  });

  tearDown(() async {
    await bloc.close();
    await devices.dispose();
    await logs.dispose();
  });

  test('submits maintenance done log', () async {
    bloc.add(const DeviceLogStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(const DeviceLogNotesChanged(' cleaned '));
    bloc.add(DeviceLogDateChanged(DateTime(2024, 3, 15)));
    bloc.add(
      const DeviceLogSubmitRequested(
        usageReadingRequiredMessage: 'reading required',
        invalidCostMessage: 'invalid cost',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceLogFormState>().having(
          (s) => s.status,
          'status',
          DeviceLogStatus.saved,
        ),
      ),
    );

    expect(logs.created, hasLength(1));
    expect(logs.created.first.notes, 'cleaned');
    expect(logs.created.first.kind, DeviceLogKind.maintenanceDone);
  });

  test('usage update requires reading', () async {
    bloc.add(const DeviceLogStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const DeviceLogKindChanged(DeviceLogKind.usageUpdate));
    bloc.add(const DeviceLogUsageValueChanged(''));
    bloc.add(
      const DeviceLogSubmitRequested(
        usageReadingRequiredMessage: 'reading required',
        invalidCostMessage: 'invalid cost',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceLogFormState>()
            .having((s) => s.status, 'status', DeviceLogStatus.failure)
            .having((s) => s.errorMessage, 'error', 'reading required'),
      ),
    );
  });

  test('submits usage update with absolute reading', () async {
    bloc.add(const DeviceLogStarted());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const DeviceLogKindChanged(DeviceLogKind.usageUpdate));
    bloc.add(const DeviceLogUsageValueChanged('1200'));
    bloc.add(
      const DeviceLogSubmitRequested(
        usageReadingRequiredMessage: 'reading required',
        invalidCostMessage: 'invalid cost',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceLogFormState>().having(
          (s) => s.status,
          'status',
          DeviceLogStatus.saved,
        ),
      ),
    );
    expect(logs.created.first.kind, DeviceLogKind.usageUpdate);
    expect(logs.created.first.usageValue, 1200);
  });

  test('submits maintenance done log without notes', () async {
    bloc.add(const DeviceLogStarted());
    await Future<void>.delayed(Duration.zero);

    bloc.add(DeviceLogDateChanged(DateTime(2024, 1, 10)));
    bloc.add(
      const DeviceLogSubmitRequested(
        usageReadingRequiredMessage: 'reading required',
        invalidCostMessage: 'invalid cost',
      ),
    );

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceLogFormState>().having(
          (s) => s.status,
          'status',
          DeviceLogStatus.saved,
        ),
      ),
    );

    expect(logs.created.single.kind, DeviceLogKind.maintenanceDone);
    expect(logs.created.single.notes, isNull);
    expect(logs.created.single.date, DateTime(2024, 1, 10));
  });

  test('resolves usage owner from parent for child device', () async {
    await devices.dispose();
    await logs.dispose();
    await bloc.close();

    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    devices.devices.addAll([
      sampleDevice(
        id: 'car',
        usageUnit: UsageIntervalUnit.km,
        currentUsage: 8500,
        scheduleType: null,
        intervalValue: null,
        intervalUnit: null,
      ),
      sampleDevice(
        id: 'oil',
        parentId: 'car',
        scheduleType: ScheduleType.usageInterval,
        intervalValue: 1000,
        intervalUnit: 'km',
        usageUnit: null,
      ),
    ]);
    bloc = DeviceLogBloc(
      deviceId: 'oil',
      createDeviceLog: CreateDeviceLogUsecase(logs),
      getDevice: GetDeviceUsecase(devices),
    );

    bloc.add(const DeviceLogStarted());
    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceLogFormState>()
            .having((s) => s.status, 'status', DeviceLogStatus.ready)
            .having((s) => s.usageOwner?.id, 'owner', 'car')
            .having((s) => s.usageValue, 'usage', '8500'),
      ),
    );
  });

  test(
    'submits maintenance done log with cost vendor and photo bytes',
    () async {
      bloc.add(const DeviceLogStarted());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const DeviceLogCostValueChanged('49.99'));
      bloc.add(const DeviceLogCostCurrencyChanged('USD'));
      bloc.add(const DeviceLogVendorChanged('Auto shop'));
      bloc.add(
        DeviceLogPhotoSelected(Uint8List.fromList([1, 2, 3]), 'receipt.jpg'),
      );
      bloc.add(
        const DeviceLogSubmitRequested(
          usageReadingRequiredMessage: 'reading required',
          invalidCostMessage: 'invalid cost',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<DeviceLogFormState>().having(
            (s) => s.status,
            'status',
            DeviceLogStatus.saved,
          ),
        ),
      );

      expect(logs.created.single.cost, 49.99);
      expect(logs.created.single.costCurrency, 'USD');
      expect(logs.created.single.vendor, 'Auto shop');
    },
  );
}
