import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/usecases/device/restore_device_usecase.dart';
import 'package:nasyad/domain/usecases/device/watch_archived_root_devices_usecase.dart';
import 'package:nasyad/presentation/device/bloc/archived_devices_bloc.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository devices;
  late ArchivedDevicesBloc bloc;

  setUp(() {
    devices = FakeDeviceRepository();
    bloc = ArchivedDevicesBloc(
      watchArchivedRootDevices: WatchArchivedRootDevicesUsecase(devices),
      restoreDevice: RestoreDeviceUsecase(devices),
    );
  });

  tearDown(() async {
    await bloc.close();
    await devices.dispose();
  });

  test('loads archived root devices', () async {
    expectLater(
      bloc.stream,
      emitsThrough(
        isA<ArchivedDevicesLoaded>().having(
          (s) => s.devices.map((d) => d.id),
          'ids',
          ['car'],
        ),
      ),
    );

    bloc.add(const ArchivedDevicesStarted());
    await Future<void>.delayed(Duration.zero);
    devices.emitArchivedRoots([
      sampleDevice(id: 'car', name: 'Car', status: DeviceStatus.archived),
    ]);
  });

  test('restore delegates to use case', () async {
    bloc.add(const ArchivedDevicesRestoreRequested('car'));
    await Future<void>.delayed(Duration.zero);
    expect(devices.statusChanges.single.$1, 'car');
    expect(devices.statusChanges.single.$2, DeviceStatus.active);
  });
}
