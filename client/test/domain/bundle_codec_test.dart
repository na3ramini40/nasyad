import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/device_category_preset.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';

import '../helpers/fixtures.dart';

void main() {
  final bundle = sampleBundle(exportedAt: DateTime.utc(2024, 6, 1, 12));

  group('format helpers', () {
    test('detectFormat recognizes json csv and plain text', () {
      expect(BundleCodec.detectFormat('{"a":1}'), ExportFormat.json);
      expect(BundleCodec.detectFormat('#devices\nid'), ExportFormat.csv);
      expect(
        BundleCodec.detectFormat('Nasyad export\nformat: nasyad'),
        ExportFormat.plainText,
      );
    });

    test('detectFormat throws for unknown content', () {
      expect(
        () => BundleCodec.detectFormat('random'),
        throwsA(isA<BundleCodecException>()),
      );
    });

    test('formatFromExtension maps known suffixes', () {
      expect(BundleCodec.formatFromExtension('a.json'), ExportFormat.json);
      expect(BundleCodec.formatFromExtension('a.CSV'), ExportFormat.csv);
      expect(BundleCodec.formatFromExtension('a.txt'), ExportFormat.plainText);
      expect(BundleCodec.formatFromExtension('a.bin'), isNull);
      expect(BundleCodec.formatFromExtension(null), isNull);
    });
  });

  group('json', () {
    test('round-trips encode and decode', () {
      final encoded = BundleCodec.encodeJson(bundle);
      final decoded = BundleCodec.decodeJson(encoded);
      expect(decoded.format, bundle.format);
      expect(decoded.version, bundle.version);
      expect(decoded.devices.first.device.id, 'device-1');
      expect(decoded.devices.first.device.hasSchedule, isTrue);
      expect(decoded.devices.first.logs, isNotEmpty);
    });

    test('round-trips birthdays and places and accepts v2 without them', () {
      final withAll = sampleBundle(
        birthdays: [sampleBirthday()],
        places: [samplePlace()],
      );
      final decoded = BundleCodec.decodeJson(BundleCodec.encodeJson(withAll));
      expect(decoded.birthdays.single.id, 'birthday-1');
      expect(decoded.birthdays.single.birthMonth, 6);
      expect(decoded.places.single.name, 'Office');

      const v2 = '''
{
  "format": "nasyad",
  "version": 2,
  "exportedAt": "2024-06-01T00:00:00.000Z",
  "devices": []
}
''';
      final old = BundleCodec.decodeJson(v2);
      expect(old.birthdays, isEmpty);
      expect(old.places, isEmpty);
      expect(old.version, ExportBundle.currentVersion);
    });

    test('preserves parentId in tree export', () {
      final tree = sampleBundle(
        devices: [
          ExportDeviceBundle(
            device: sampleDevice(
              id: 'car',
              scheduleType: null,
              intervalValue: null,
              intervalUnit: null,
            ),
            logs: const [],
          ),
          ExportDeviceBundle(
            device: sampleDevice(
              id: 'oil',
              parentId: 'car',
              scheduleType: ScheduleType.usageInterval,
              intervalValue: 1000,
              intervalUnit: 'km',
            ),
            logs: const [],
          ),
        ],
      );
      final decoded = BundleCodec.decodeJson(BundleCodec.encodeJson(tree));
      final oil = decoded.devices.firstWhere((d) => d.device.id == 'oil');
      expect(oil.device.parentId, 'car');
      expect(oil.device.intervalValue, 1000);
    });

    test('folds legacy v1 rules into device schedule', () {
      const legacy = '''
{
  "format": "nasyad",
  "version": 1,
  "exportedAt": "2024-06-01T00:00:00.000Z",
  "devices": [
    {
      "id": "washer",
      "name": "Washer",
      "description": "",
      "status": "active",
      "currentUsage": 0,
      "usageAtLastMaintenance": 0,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z",
      "rules": [
        {
          "id": "r1",
          "deviceId": "washer",
          "name": "Every 6 months",
          "scheduleType": "calendarInterval",
          "intervalValue": 6,
          "intervalUnit": "months",
          "fixedDueAt": null,
          "createdAt": "2024-01-01T00:00:00.000Z",
          "updatedAt": "2024-01-01T00:00:00.000Z"
        }
      ],
      "logs": []
    }
  ]
}
''';
      final decoded = BundleCodec.decodeJson(legacy);
      expect(decoded.version, ExportBundle.currentVersion);
      final device = decoded.devices.single.device;
      expect(device.hasSchedule, isTrue);
      expect(device.scheduleType, ScheduleType.calendarInterval);
      expect(device.intervalValue, 6);
      expect(device.intervalUnit, 'months');
    });

    test('round-trips device metadata fields', () {
      final withMetadata = sampleBundle(
        devices: [
          ExportDeviceBundle(
            device: sampleDevice(
              categoryPreset: DeviceCategoryPreset.car,
              locationLabel: 'Garage',
              description: 'Family SUV',
            ),
            logs: const [],
          ),
        ],
      );
      for (final format in ExportFormat.values) {
        final decoded = BundleCodec.decode(
          BundleCodec.encode(withMetadata, format),
          format: format,
        );
        final device = decoded.devices.single.device;
        expect(device.categoryPreset, DeviceCategoryPreset.car);
        expect(device.locationLabel, 'Garage');
        expect(device.description, 'Family SUV');
      }
    });

    test('rejects invalid json and unsupported version', () {
      expect(
        () => BundleCodec.decodeJson('not-json'),
        throwsA(isA<BundleCodecException>()),
      );
      expect(
        () => BundleCodec.decodeJson(
          '{"format":"nasyad","version":99,"devices":[]}',
        ),
        throwsA(isA<BundleCodecException>()),
      );
    });
  });

  group('csv', () {
    test('round-trips encode and decode', () {
      final encoded = BundleCodec.encodeCsv(bundle);
      final decoded = BundleCodec.decodeCsv(encoded);
      expect(decoded.devices, hasLength(1));
      expect(decoded.devices.first.device.name, 'Pump');
      expect(decoded.devices.first.device.intervalValue, 3);
      expect(decoded.devices.first.logs.first.id, 'log-1');
    });

    test('escapes commas in fields', () {
      final withComma = sampleBundle(
        devices: [
          ExportDeviceBundle(
            device: sampleDevice(name: 'Pump, A'),
            logs: const [],
          ),
        ],
      );
      final encoded = BundleCodec.encodeCsv(withComma);
      expect(encoded, contains('"Pump, A"'));
      final decoded = BundleCodec.decodeCsv(encoded);
      expect(decoded.devices.first.device.name, 'Pump, A');
    });

    test('throws when no transferable sections', () {
      expect(
        () => BundleCodec.decodeCsv('#devices\nid,name\n'),
        throwsA(isA<BundleCodecException>()),
      );
    });

    test('round-trips birthdays and places', () {
      final withAll = sampleBundle(
        birthdays: [sampleBirthday()],
        places: [samplePlace()],
      );
      final decoded = BundleCodec.decodeCsv(BundleCodec.encodeCsv(withAll));
      expect(decoded.birthdays.single.name, 'Ali');
      expect(decoded.places.single.id, 'place-1');
    });
  });

  group('plain text', () {
    test('round-trips encode and decode', () {
      final encoded = BundleCodec.encodePlainText(bundle);
      final decoded = BundleCodec.decodePlainText(encoded);
      expect(decoded.devices.first.device.id, 'device-1');
      expect(decoded.devices.first.device.hasSchedule, isTrue);
      expect(decoded.devices.first.logs, hasLength(1));
    });
  });

  group('encode/decode facade', () {
    test('dispatches by format', () {
      for (final format in ExportFormat.values) {
        final content = BundleCodec.encode(bundle, format);
        final decoded = BundleCodec.decode(content, format: format);
        expect(decoded.devices.first.device.id, 'device-1');
      }
    });
  });
}
