import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/services/transfer/birthday_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/device_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/place_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/transfer_service.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fake_log_photo_storage.dart';
import '../../helpers/fixtures.dart';

TransferService buildTransfer({
  required FakeDeviceRepository devices,
  required FakeDeviceLogRepository logs,
  required FakeBirthdayRepository birthdays,
  required FakePlaceRepository places,
  FakeLogPhotoStorage? photos,
  bool includeDevices = true,
  bool includeBirthdays = true,
  bool includePlaces = true,
}) {
  return TransferService([
    if (includeDevices)
      DeviceTransferHandler(devices, logs, photos ?? FakeLogPhotoStorage()),
    if (includeBirthdays) BirthdayTransferHandler(birthdays),
    if (includePlaces) PlaceTransferHandler(places),
  ]);
}

void main() {
  late FakeDeviceRepository devices;
  late FakeDeviceLogRepository logs;
  late FakeBirthdayRepository birthdays;
  late FakePlaceRepository places;
  late FakeLogPhotoStorage photos;

  setUp(() {
    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    birthdays = FakeBirthdayRepository();
    places = FakePlaceRepository();
    photos = FakeLogPhotoStorage();
  });

  tearDown(() async {
    await devices.dispose();
    await logs.dispose();
    await birthdays.dispose();
    await places.dispose();
  });

  group('ExportDataUsecase', () {
    test('exports all devices as json', () async {
      devices.devices.add(sampleDevice());
      logs.logsByDevice['device-1'] = [sampleLog()];

      final result = await ExportDataUsecase(
        buildTransfer(
          devices: devices,
          logs: logs,
          birthdays: birthdays,
          places: places,
          photos: photos,
        ),
      )(scope: ExportScopeKind.all, format: ExportFormat.json);

      expect(result.bundle.deviceCount, 1);
      expect(result.format, ExportFormat.json);
      expect(result.fileName, endsWith('.json'));
      expect(result.content, contains('"Pump"'));
    });

    test('exports birthdays with devices', () async {
      devices.devices.add(sampleDevice());
      birthdays.items.add(sampleBirthday());

      final result = await ExportDataUsecase(
        buildTransfer(
          devices: devices,
          logs: logs,
          birthdays: birthdays,
          places: places,
          photos: photos,
        ),
      )(scope: ExportScopeKind.all, format: ExportFormat.json);

      expect(result.bundle.birthdayCount, 1);
      expect(result.content, contains('"Ali"'));
    });

    test('validates one and selected scopes', () async {
      final usecase = ExportDataUsecase(
        buildTransfer(
          devices: devices,
          logs: logs,
          birthdays: birthdays,
          places: places,
          photos: photos,
        ),
      );
      expect(
        () => usecase(
          scope: ExportScopeKind.one,
          format: ExportFormat.json,
          deviceIds: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => usecase(
          scope: ExportScopeKind.selected,
          format: ExportFormat.json,
          deviceIds: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when no data found', () async {
      expect(
        () => ExportDataUsecase(
          buildTransfer(
            devices: devices,
            logs: logs,
            birthdays: birthdays,
            places: places,
            photos: photos,
          ),
        )(scope: ExportScopeKind.all, format: ExportFormat.csv),
        throwsA(isA<StateError>()),
      );
    });

    test('exports selected devices and still includes birthdays', () async {
      devices.devices.addAll([
        sampleDevice(id: 'a', name: 'A'),
        sampleDevice(id: 'b', name: 'B'),
      ]);
      birthdays.items.add(sampleBirthday());

      final result =
          await ExportDataUsecase(
            buildTransfer(
              devices: devices,
              logs: logs,
              birthdays: birthdays,
              places: places,
              photos: photos,
            ),
          )(
            scope: ExportScopeKind.selected,
            format: ExportFormat.csv,
            deviceIds: const ['a'],
          );

      expect(result.bundle.devices.map((d) => d.device.id), ['a']);
      expect(result.bundle.birthdayCount, 1);
      expect(result.fileName, endsWith('.csv'));
    });
  });

  group('ImportDataUsecase', () {
    test('preview and import decode content', () async {
      final content = BundleCodec.encodeJson(
        sampleBundle(birthdays: [sampleBirthday()]),
      );
      final usecase = ImportDataUsecase(
        buildTransfer(
          devices: devices,
          logs: logs,
          birthdays: birthdays,
          places: places,
          photos: photos,
        ),
      );

      final preview = usecase.preview(content, fileName: 'backup.json');
      expect(preview.deviceCount, 1);
      expect(preview.birthdayCount, 1);

      final result = await usecase(content, fileName: 'backup.json');
      expect(result.format, ExportFormat.json);
      expect(devices.lastImported?.deviceCount, 1);
      expect(devices.devices, hasLength(1));
      expect(birthdays.items, hasLength(1));
      expect(birthdays.items.single.name, 'Ali');
    });

    test('imports birthdays-only bundle', () async {
      final content = BundleCodec.encodeJson(
        ExportBundle(
          exportedAt: tNow,
          birthdays: [
            sampleBirthday(
              calendarSystem: CalendarSystem.persian,
              birthMonth: 1,
              birthDay: 2,
            ),
          ],
        ),
      );

      await ImportDataUsecase(
        buildTransfer(
          devices: devices,
          logs: logs,
          birthdays: birthdays,
          places: places,
          photos: photos,
        ),
      )(content, fileName: 'b.json');

      expect(devices.devices, isEmpty);
      expect(birthdays.items.single.calendarSystem, CalendarSystem.persian);
      expect(birthdays.items.single.birthMonth, 1);
    });
  });
}
