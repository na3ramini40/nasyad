import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/usecases/device/archive_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_device_summary_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/watch_logs_for_device_usecase.dart';
import 'package:nasyad/presentation/device/bloc/device_detail_bloc.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository devices;
  late FakeDeviceLogRepository logs;
  late DeviceDetailBloc bloc;

  setUp(() {
    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    bloc = DeviceDetailBloc(
      deviceId: 'device-1',
      watchDeviceSummary: WatchDeviceSummaryUsecase(devices),
      watchLogsForDevice: WatchLogsForDeviceUsecase(logs),
      archiveDevice: ArchiveDeviceUsecase(devices),
    );
  });

  tearDown(() async {
    await bloc.close();
    await devices.dispose();
    await logs.dispose();
  });

  test('loads summary and logs', () async {
    expectLater(
      bloc.stream,
      emitsThrough(
        isA<DeviceDetailLoaded>()
            .having((s) => s.summary.device.id, 'id', 'device-1')
            .having((s) => s.logs, 'logs', hasLength(1)),
      ),
    );

    bloc.add(const DeviceDetailStarted());
    await Future<void>.delayed(Duration.zero);
    devices.emitDetail(sampleSummary());
    logs.emitLogs([sampleLog()]);
  });

  test('emits not found when device missing', () async {
    expectLater(bloc.stream, emitsThrough(isA<DeviceDetailNotFound>()));

    bloc.add(const DeviceDetailStarted());
    await Future<void>.delayed(Duration.zero);
    devices.emitDetail(null);
  });

  test('archives device', () async {
    bloc.add(const DeviceDetailArchiveRequested());
    await expectLater(bloc.stream, emitsThrough(isA<DeviceDetailArchived>()));
    expect(devices.statusChanges.first.$2.name, 'archived');
  });
}
