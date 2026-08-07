import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/models/device_log_model.dart';
import 'package:nasyad/data/models/device_model.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/interval_unit.dart';

import '../helpers/fixtures.dart';

void main() {
  group('DeviceModel', () {
    test('maps to and from entity', () {
      final entity = sampleDevice();
      final model = DeviceModel.fromEntity(entity);
      expect(model.toEntity(), entity);
      expect(model.status, DeviceStatus.active);

      final table = model.toTableData();
      expect(DeviceModel.fromTableData(table).toEntity(), entity);

      final companion = model.toCompanion();
      expect(companion.id.value, entity.id);
      expect(companion.name.value, entity.name);
    });
  });

  group('DeviceLogModel', () {
    test('maps to and from entity', () {
      final entity = sampleLog();
      final model = DeviceLogModel.fromEntity(entity);
      expect(model.toEntity(), entity);
      expect(model.usageUnit, UsageIntervalUnit.hours);

      final companion = model.toCompanion();
      expect(companion.id.value, entity.id);
      expect(companion.deviceId.value, entity.deviceId);
    });
  });
}
