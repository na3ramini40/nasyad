import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';
import 'package:nasyad/domain/services/schedule_due_offset.dart';
import 'package:nasyad/domain/services/schedule_template_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(ScheduleTemplateCatalog.resetCacheForTesting);

  group('ScheduleTemplateCatalog.parse', () {
    test('parses valid bundled template JSON', () {
      const json = '''
{
  "version": 1,
  "templates": [
    {
      "id": "demo",
      "label": {"en": "Demo", "fa": "نمونه"},
      "scheduleType": "calendarInterval",
      "intervalValue": 3,
      "intervalUnit": "months"
    }
  ]
}
''';

      final templates = ScheduleTemplateCatalog.parse(json);
      expect(templates, hasLength(1));
      expect(templates.single.id, 'demo');
      expect(templates.single.labelEn, 'Demo');
      expect(templates.single.labelFa, 'نمونه');
      expect(templates.single.scheduleType, ScheduleType.calendarInterval);
      expect(templates.single.intervalValue, 3);
      expect(templates.single.intervalUnit, 'months');
    });

    test('rejects template missing fa label', () {
      const json = '''
{
  "templates": [
    {
      "id": "bad",
      "label": {"en": "Only English"},
      "scheduleType": "usageInterval",
      "intervalValue": 1000,
      "intervalUnit": "km"
    }
  ]
}
''';

      expect(
        () => ScheduleTemplateCatalog.parse(json),
        throwsA(isA<ScheduleTemplateCatalogException>()),
      );
    });

    test('loads bundled asset file', () async {
      final templates = await ScheduleTemplateCatalog.load();
      expect(templates.length, greaterThanOrEqualTo(6));
      expect(
        templates.map((template) => template.id),
        contains('oil_change_5000km'),
      );
      expect(
        templates.singleWhere((t) => t.id == 'oil_change_5000km').labelFa,
        contains('تعویض'),
      );
    });
  });

  group('dueDateFromInterval', () {
    test('adds months for fixed-date templates', () {
      final from = DateTime(2026, 1, 15);
      final due = dueDateFromInterval(
        intervalValue: 3,
        intervalUnit: 'months',
        from: from,
      );
      expect(due, DateTime(2026, 4, 15));
    });
  });
}
