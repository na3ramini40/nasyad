import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/services/transfer/birthday_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/device_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/place_transfer_handler.dart';
import 'package:nasyad/domain/services/transfer/transfer_service.dart';

import '../../helpers/fake_log_photo_storage.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository devices;
  late FakeDeviceLogRepository logs;
  late FakeBirthdayRepository birthdays;
  late FakePlaceRepository places;

  setUp(() {
    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    birthdays = FakeBirthdayRepository();
    places = FakePlaceRepository();
  });

  tearDown(() async {
    await devices.dispose();
    await logs.dispose();
    await birthdays.dispose();
    await places.dispose();
  });

  TransferService fullService() => TransferService([
    DeviceTransferHandler(devices, logs, FakeLogPhotoStorage()),
    BirthdayTransferHandler(birthdays),
    PlaceTransferHandler(places),
  ]);

  test('export includes devices birthdays and places', () async {
    devices.devices.add(sampleDevice());
    logs.logsByDevice['device-1'] = [sampleLog()];
    birthdays.items.add(sampleBirthday());
    places.items.add(samplePlace());

    final bundle = await fullService().export(scope: ExportScopeKind.all);

    expect(bundle.deviceCount, 1);
    expect(bundle.logCount, 1);
    expect(bundle.birthdayCount, 1);
    expect(bundle.placeCount, 1);
    expect(bundle.version, ExportBundle.currentVersion);
  });

  test('import restores all three kinds', () async {
    final source = sampleBundle(
      birthdays: [sampleBirthday()],
      places: [samplePlace()],
    );

    await fullService().import(source);

    expect(devices.devices, hasLength(1));
    expect(birthdays.items.single.id, 'birthday-1');
    expect(places.items.single.name, 'Office');
  });

  test('import accepts old v2 devices-only json via codec', () async {
    const legacy = '''
{
  "format": "nasyad",
  "version": 2,
  "exportedAt": "2024-06-01T00:00:00.000Z",
  "devices": [
    {
      "id": "washer",
      "name": "Washer",
      "status": "active",
      "currentUsage": 0,
      "usageAtLastMaintenance": 0,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z",
      "logs": []
    }
  ]
}
''';
    final bundle = BundleCodec.decodeJson(legacy);
    expect(bundle.birthdays, isEmpty);
    expect(bundle.places, isEmpty);

    await fullService().import(bundle);
    expect(devices.devices.single.id, 'washer');
    expect(birthdays.items, isEmpty);
    expect(places.items, isEmpty);
  });

  test('subset of handlers still exports and imports', () async {
    birthdays.items.add(sampleBirthday());
    places.items.add(samplePlace());

    final birthdaysOnly = TransferService([BirthdayTransferHandler(birthdays)]);
    final exported = await birthdaysOnly.export(scope: ExportScopeKind.all);
    expect(exported.devices, isEmpty);
    expect(exported.birthdayCount, 1);
    expect(exported.places, isEmpty);

    final targetBirthdays = FakeBirthdayRepository();
    final importer = TransferService([
      BirthdayTransferHandler(targetBirthdays),
    ]);
    await importer.import(exported);
    expect(targetBirthdays.items.single.name, 'Ali');
    await targetBirthdays.dispose();
  });

  test('json and csv round-trip through codec with all sections', () async {
    final original = sampleBundle(
      birthdays: [sampleBirthday()],
      places: [samplePlace(kind: samplePlace().kind)],
    );
    for (final format in [ExportFormat.json, ExportFormat.csv]) {
      final decoded = BundleCodec.decode(
        BundleCodec.encode(original, format),
        format: format,
      );
      expect(decoded.devices.single.device.id, 'device-1');
      expect(decoded.birthdays.single.id, 'birthday-1');
      expect(decoded.places.single.id, 'place-1');
    }
  });
}
