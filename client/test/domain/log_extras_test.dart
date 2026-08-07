import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/export_bundle.dart';
import 'package:nasyad/domain/entities/export_format.dart';
import 'package:nasyad/domain/services/bundle_codec.dart';

import '../helpers/fixtures.dart';

void main() {
  test('json round-trips log cost vendor and photoBase64', () {
    final log = sampleLog(
      cost: 49.99,
      costCurrency: 'USD',
      vendor: 'Auto shop',
      photoBase64: 'aGVsbG8=',
    );
    final bundle = sampleBundle(
      devices: [
        ExportDeviceBundle(device: sampleDevice(), logs: [log]),
      ],
    );

    final decoded = BundleCodec.decodeJson(BundleCodec.encodeJson(bundle));
    final imported = decoded.devices.single.logs.single;
    expect(imported.cost, 49.99);
    expect(imported.costCurrency, 'USD');
    expect(imported.vendor, 'Auto shop');
    expect(imported.photoBase64, 'aGVsbG8=');
  });

  test('csv round-trips log extras', () {
    final log = sampleLog(cost: 12.5, vendor: 'Garage');
    final bundle = sampleBundle(
      devices: [
        ExportDeviceBundle(device: sampleDevice(), logs: [log]),
      ],
    );

    final decoded = BundleCodec.decodeCsv(BundleCodec.encodeCsv(bundle));
    final imported = decoded.devices.single.logs.single;
    expect(imported.cost, 12.5);
    expect(imported.vendor, 'Garage');
  });

  test('plain text round-trips log extras', () {
    final log = sampleLog(cost: 5, costCurrency: 'EUR', vendor: 'Shop');
    final bundle = sampleBundle(
      devices: [
        ExportDeviceBundle(device: sampleDevice(), logs: [log]),
      ],
    );

    final decoded = BundleCodec.decodePlainText(
      BundleCodec.encodePlainText(bundle),
    );
    final imported = decoded.devices.single.logs.single;
    expect(imported.cost, 5);
    expect(imported.costCurrency, 'EUR');
    expect(imported.vendor, 'Shop');
  });

  test('encode facade includes extras for all formats', () {
    final log = sampleLog(cost: 1, vendor: 'V');
    final bundle = sampleBundle(
      devices: [
        ExportDeviceBundle(device: sampleDevice(), logs: [log]),
      ],
    );

    for (final format in ExportFormat.values) {
      final content = BundleCodec.encode(bundle, format);
      final decoded = BundleCodec.decode(content, format: format);
      expect(decoded.devices.single.logs.single.vendor, 'V');
    }
  });
}
