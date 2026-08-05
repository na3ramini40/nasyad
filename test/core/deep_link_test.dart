import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/deep_link/deep_link_constants.dart';
import 'package:nasyad/core/deep_link/deep_link_mapper.dart';
import 'package:nasyad/core/deep_link/deep_link_parser.dart';
import 'package:nasyad/core/deep_link/deep_link_resolver.dart';
import 'package:nasyad/core/deep_link/deep_link_target.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';

void main() {
  group('DeepLinkParser', () {
    test('rejects non-nasyad schemes', () {
      expect(DeepLinkParser.parse(Uri.parse('https:///devices')), isNull);
    });

    test('parses home', () {
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///')),
        isA<DeepLinkHome>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///')),
        isA<DeepLinkHome>(),
      );
    });

    test('parses top-level routes from path form', () {
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///devices')),
        isA<DeepLinkDevices>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///preferences')),
        isA<DeepLinkPreferences>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///preferences/transfer')),
        isA<DeepLinkTransfer>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///birthdays')),
        isA<DeepLinkBirthdays>(),
      );
    });

    test('parses top-level routes from host form', () {
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad://devices')),
        isA<DeepLinkDevices>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad://preferences/transfer')),
        isA<DeepLinkTransfer>(),
      );
    });

    test('parses birthday routes', () {
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///birthdays/new')),
        isA<DeepLinkBirthdayNew>(),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///birthdays/b-1/edit')),
        const DeepLinkBirthdayEdit(id: 'b-1'),
      );
    });

    test('parses device routes', () {
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///device/new')),
        isA<DeepLinkDeviceNew>(),
      );
      expect(
        DeepLinkParser.parse(
          Uri.parse('nasyad:///device/new?parentId=parent-1'),
        ),
        const DeepLinkDeviceNew(parentId: 'parent-1'),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///device/d-1')),
        const DeepLinkDeviceView(id: 'd-1'),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///device/d-1/edit')),
        const DeepLinkDeviceEdit(id: 'd-1'),
      );
    });

    test('parses device log kind query', () {
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///device/d-1/log?kind=usage')),
        const DeepLinkDeviceLog(id: 'd-1', kind: DeviceLogKind.usageUpdate),
      );
      expect(
        DeepLinkParser.parse(
          Uri.parse('nasyad:///device/d-1/log?kind=maintenance'),
        ),
        const DeepLinkDeviceLog(id: 'd-1', kind: DeviceLogKind.maintenanceDone),
      );
      expect(
        DeepLinkParser.parse(Uri.parse('nasyad:///device/d-1/log')),
        const DeepLinkDeviceLog(id: 'd-1'),
      );
    });

    test('returns null for unknown paths', () {
      expect(DeepLinkParser.parse(Uri.parse('nasyad:///splash')), isNull);
      expect(DeepLinkParser.parse(Uri.parse('nasyad:///unknown')), isNull);
    });
  });

  group('DeepLinkMapper', () {
    test('maps targets to go_router locations', () {
      expect(DeepLinkMapper.toLocation(const DeepLinkHome()), '/');
      expect(DeepLinkMapper.toLocation(const DeepLinkDevices()), '/devices');
      expect(
        DeepLinkMapper.toLocation(const DeepLinkTransfer()),
        '/preferences/transfer',
      );
      expect(
        DeepLinkMapper.toLocation(const DeepLinkBirthdayEdit(id: 'b-1')),
        '/birthdays/b-1/edit',
      );
      expect(
        DeepLinkMapper.toLocation(const DeepLinkDeviceView(id: 'd-1')),
        '/device/d-1',
      );
    });

    test('maps query parameters', () {
      expect(
        DeepLinkMapper.toLocation(
          const DeepLinkDeviceNew(parentId: 'parent-1'),
        ),
        '/device/new?parentId=parent-1',
      );
      expect(
        DeepLinkMapper.toLocation(
          const DeepLinkDeviceLog(id: 'd-1', kind: DeviceLogKind.usageUpdate),
        ),
        '/device/d-1/log?kind=usage',
      );
    });
  });

  group('DeepLinkResolver', () {
    test('round-trips canonical URIs to locations', () {
      expect(
        DeepLinkResolver.resolveLocation(Uri.parse('nasyad:///devices')),
        '/devices',
      );
      expect(
        DeepLinkResolver.resolveLocationFromString('nasyad:///device/d-1/edit'),
        '/device/d-1/edit',
      );
    });

    test('uses nasyad scheme constant', () {
      expect(DeepLinkConstants.scheme, 'nasyad');
    });
  });
}
