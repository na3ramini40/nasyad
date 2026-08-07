import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';
import 'package:nasyad/domain/usecases/transfer/export_data_usecase.dart';
import 'package:nasyad/domain/usecases/transfer/import_data_usecase.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fake_log_photo_storage.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository devices;
  late FakeDeviceLogRepository logs;

  late FakeLogPhotoStorage photos;

  setUp(() {
    devices = FakeDeviceRepository();
    logs = FakeDeviceLogRepository();
    photos = FakeLogPhotoStorage();
  });

  tearDown(() async {
    await devices.dispose();
    await logs.dispose();
  });

  group('ExportDataUsecase', () {
    test('exports all devices as json', () async {
      devices.devices.add(sampleDevice());
      logs.logsByDevice['device-1'] = [sampleLog()];

      final result = await ExportDataUsecase(devices, logs, photos)(
        scope: ExportScopeKind.all,
        format: ExportFormat.json,
      );

      expect(result.bundle.deviceCount, 1);
      expect(result.format, ExportFormat.json);
      expect(result.fileName, endsWith('.json'));
      expect(result.content, contains('"Pump"'));
    });

    test('validates one and selected scopes', () async {
      final usecase = ExportDataUsecase(devices, logs, photos);
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

    test('throws when no devices found', () async {
      expect(
        () => ExportDataUsecase(devices, logs, photos)(
          scope: ExportScopeKind.all,
          format: ExportFormat.csv,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('exports selected devices', () async {
      devices.devices.addAll([
        sampleDevice(id: 'a', name: 'A'),
        sampleDevice(id: 'b', name: 'B'),
      ]);

      final result = await ExportDataUsecase(devices, logs, photos)(
        scope: ExportScopeKind.selected,
        format: ExportFormat.csv,
        deviceIds: const ['a'],
      );

      expect(result.bundle.devices.map((d) => d.device.id), ['a']);
      expect(result.fileName, endsWith('.csv'));
    });
  });

  group('ImportDataUsecase', () {
    test('preview and import decode content', () async {
      final content = BundleCodec.encodeJson(sampleBundle());
      final usecase = ImportDataUsecase(devices);

      final preview = usecase.preview(content, fileName: 'backup.json');
      expect(preview.deviceCount, 1);

      final result = await usecase(content, fileName: 'backup.json');
      expect(result.format, ExportFormat.json);
      expect(devices.lastImported?.deviceCount, 1);
      expect(devices.devices, hasLength(1));
    });
  });
}
