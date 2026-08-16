import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nasyad/core/calendar/preferred_datetime_formatter.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/services/device_history_plain_text.dart';
import 'package:nasyad/domain/services/device_history_share_builder.dart';
import 'package:nasyad/domain/usecases/device/prepare_device_history_share_usecase.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:nasyad/domain/services/device_history_pdf_builder.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

void main() {
  group('buildDeviceHistoryShare', () {
    test('filters maintenanceDone only and sorts oldest first', () {
      final summary = sampleSummary();
      final doc = buildDeviceHistoryShare(
        summary: summary,
        logsByDeviceId: {
          'device-1': [
            sampleLog(
              id: 'newer',
              date: DateTime.utc(2024, 6, 1),
              notes: 'Later service',
            ),
            sampleLog(
              id: 'usage',
              date: DateTime.utc(2024, 3, 1),
              kind: DeviceLogKind.usageUpdate,
              notes: 'Usage only',
            ),
            sampleLog(
              id: 'older',
              date: DateTime.utc(2024, 2, 1),
              notes: 'Earlier service',
              vendor: 'Acme',
              cost: 12.5,
              costCurrency: 'USD',
            ),
          ],
        },
        title: 'Pump maintenance history',
      );

      expect(doc, isNotNull);
      expect(doc!.root.lines, hasLength(2));
      expect(doc.root.lines.first.notes, 'Earlier service');
      expect(doc.root.lines.last.notes, 'Later service');
      expect(doc.root.lines.first.vendor, 'Acme');
      expect(doc.root.lines.first.cost, 12.5);
    });

    test('includes nested children with their maintenance', () {
      final child = sampleSummary(
        device: sampleDevice(
          id: 'child-1',
          parentId: 'device-1',
          name: 'Filter',
        ),
      );
      final summary = sampleSummary(children: [child]);
      final doc = buildDeviceHistoryShare(
        summary: summary,
        logsByDeviceId: {
          'device-1': [sampleLog(id: 'root-log', notes: 'Root service')],
          'child-1': [
            sampleLog(
              id: 'child-log',
              deviceId: 'child-1',
              notes: 'Filter change',
            ),
          ],
        },
        title: 'History',
      );

      expect(doc, isNotNull);
      expect(doc!.root.name, 'Pump');
      expect(doc.root.children, hasLength(1));
      expect(doc.root.children.single.name, 'Filter');
      expect(doc.root.children.single.lines.single.notes, 'Filter change');
    });

    test('returns null when subtree has no maintenance', () {
      final child = sampleSummary(
        device: sampleDevice(
          id: 'child-1',
          parentId: 'device-1',
          name: 'Filter',
        ),
      );
      final summary = sampleSummary(children: [child]);
      final doc = buildDeviceHistoryShare(
        summary: summary,
        logsByDeviceId: {
          'device-1': [
            sampleLog(kind: DeviceLogKind.usageUpdate, notes: 'usage'),
          ],
          'child-1': const [],
        },
        title: 'History',
      );

      expect(doc, isNull);
    });

    test('prunes child branches without maintenance', () {
      final emptyChild = sampleSummary(
        device: sampleDevice(id: 'empty', parentId: 'device-1', name: 'Empty'),
      );
      final useful = sampleSummary(
        device: sampleDevice(
          id: 'useful',
          parentId: 'device-1',
          name: 'Useful',
        ),
      );
      final summary = sampleSummary(children: [emptyChild, useful]);
      final doc = buildDeviceHistoryShare(
        summary: summary,
        logsByDeviceId: {
          'device-1': const [],
          'empty': const [],
          'useful': [sampleLog(id: 'u1', deviceId: 'useful', notes: 'Done')],
        },
        title: 'History',
      );

      expect(doc, isNotNull);
      expect(doc!.root.children.map((c) => c.name), ['Useful']);
    });
  });

  group('renderDeviceHistoryPlainText', () {
    test('contains expected device and log fields', () {
      final doc = buildDeviceHistoryShare(
        summary: sampleSummary(
          device: sampleDevice(
            name: 'Pump',
            locationLabel: 'Basement',
            description: 'Main pump',
          ),
        ),
        logsByDeviceId: {
          'device-1': [
            sampleLog(
              notes: 'Oil change',
              vendor: 'Shop',
              cost: 40,
              costCurrency: 'USD',
              date: DateTime.utc(2024, 2, 1, 12),
            ),
          ],
        },
        title: 'Pump maintenance history',
      )!;

      final text = renderDeviceHistoryPlainText(
        doc,
        formatDate: (d) => 'DATE:${d.toUtc().toIso8601String()}',
        formatCost: (cost, currency) => '$cost ${currency ?? ''}'.trim(),
      );

      expect(text, contains('Pump maintenance history'));
      expect(text, contains('Pump'));
      expect(text, contains('Basement'));
      expect(text, contains('Main pump'));
      expect(text, contains('Oil change'));
      expect(text, contains('Shop'));
      expect(text, contains('40.0 USD'));
    });
  });

  group('buildDeviceHistoryPdf', () {
    test('produces non-empty PDF bytes for sample data', () async {
      final doc = buildDeviceHistoryShare(
        summary: sampleSummary(),
        logsByDeviceId: {
          'device-1': [sampleLog(notes: 'Serviced')],
        },
        title: 'Pump maintenance history',
      )!;

      final bytes = await buildDeviceHistoryPdf(
        doc,
        font: pw.Font.helvetica(),
        formatDate: (d) => d.toIso8601String(),
        formatCost: (cost, currency) => '$cost',
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });

  group('PrepareDeviceHistoryShareUsecase', () {
    test('loads logs for root and children', () async {
      final logs = FakeDeviceLogRepository();
      logs.logsByDevice['device-1'] = [sampleLog(id: 'r1', notes: 'Root')];
      logs.logsByDevice['child-1'] = [
        sampleLog(id: 'c1', deviceId: 'child-1', notes: 'Child'),
      ];
      final usecase = PrepareDeviceHistoryShareUsecase(logs);
      final summary = sampleSummary(
        children: [
          sampleSummary(
            device: sampleDevice(
              id: 'child-1',
              parentId: 'device-1',
              name: 'Filter',
            ),
          ),
        ],
      );

      final doc = await usecase(summary: summary, documentTitle: 'History');

      expect(doc, isNotNull);
      expect(doc!.root.lines.single.notes, 'Root');
      expect(doc.root.children.single.lines.single.notes, 'Child');
    });
  });

  group('formatPreferredDateTime', () {
    setUpAll(() async {
      await initializeDateFormatting('en');
    });

    test('uses Jalali digits for persian calendar', () {
      final label = formatPreferredDateTime(
        DateTime(2024, 3, 20, 10, 30),
        calendar: CalendarSystem.persian,
        locale: const Locale('en'),
      );
      expect(label, startsWith('1403/'));
    });

    test('uses Gregorian DateFormat for gregorian calendar', () {
      final label = formatPreferredDateTime(
        DateTime(2024, 3, 20, 10, 30),
        calendar: CalendarSystem.gregorian,
        locale: const Locale('en'),
      );
      expect(label, contains('2024'));
      expect(label, contains('Mar'));
    });
  });
}
