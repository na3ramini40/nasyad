import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device_status.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/domain/usecases/search/search_usecase.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeDeviceRepository deviceRepository;
  late FakeBirthdayRepository birthdayRepository;
  late FakePlaceRepository placeRepository;
  late SearchUsecase usecase;

  setUp(() {
    deviceRepository = FakeDeviceRepository();
    birthdayRepository = FakeBirthdayRepository();
    placeRepository = FakePlaceRepository();
    usecase = SearchUsecase(
      deviceRepository,
      birthdayRepository,
      placeRepository,
    );
  });

  tearDown(() async {
    await deviceRepository.dispose();
    await birthdayRepository.dispose();
    await placeRepository.dispose();
  });

  test('returns empty results for blank query', () async {
    final results = await usecase('   ');
    expect(results.devices, isEmpty);
    expect(results.birthdays, isEmpty);
    expect(results.places, isEmpty);
  });

  test('finds active devices by partial name', () async {
    deviceRepository.devices.addAll([
      sampleDevice(id: 'root', name: 'Car'),
      sampleDevice(id: 'child', parentId: 'root', name: 'Engine'),
      sampleDevice(id: 'other', name: 'Laptop'),
    ]);

    final results = await usecase('eng');

    expect(results.devices, hasLength(1));
    expect(results.devices.first.device.id, 'child');
    expect(results.devices.first.pathSegments, ['Car', 'Engine']);
    expect(results.birthdays, isEmpty);
    expect(results.places, isEmpty);
  });

  test('excludes archived devices from search', () async {
    deviceRepository.devices.add(
      sampleDevice(
        id: 'archived',
        name: 'Old Pump',
        status: DeviceStatus.archived,
      ),
    );

    final results = await usecase('pump');

    expect(results.devices, isEmpty);
  });

  test('finds birthdays by partial name', () async {
    final now = DateTime(2026, 1, 1);
    birthdayRepository.items.addAll([
      Birthday(
        id: 'b1',
        name: 'Ada Lovelace',
        birthMonth: 12,
        birthDay: 10,
        calendarSystem: CalendarSystem.gregorian,
        createdAt: now,
        updatedAt: now,
      ),
      Birthday(
        id: 'b2',
        name: 'Grace Hopper',
        birthMonth: 12,
        birthDay: 9,
        calendarSystem: CalendarSystem.gregorian,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    final results = await usecase('ada');

    expect(results.birthdays, hasLength(1));
    expect(results.birthdays.first.id, 'b1');
    expect(results.devices, isEmpty);
    expect(results.places, isEmpty);
  });

  test('finds places by partial name', () async {
    final now = DateTime(2026, 1, 1);
    placeRepository.items.add(
      Place(
        id: 'p1',
        name: 'Central Park',
        kind: PlaceGeometryKind.point,
        points: const [GeoPoint(latitude: 1, longitude: 2)],
        createdAt: now,
        updatedAt: now,
      ),
    );

    final results = await usecase('park');

    expect(results.places, hasLength(1));
    expect(results.places.first.id, 'p1');
    expect(results.devices, isEmpty);
    expect(results.birthdays, isEmpty);
  });

  test('returns device, birthday, and place matches', () async {
    deviceRepository.devices.add(sampleDevice(id: 'd1', name: 'Sam Device'));
    final now = DateTime(2026, 1, 1);
    birthdayRepository.items.add(
      Birthday(
        id: 'b1',
        name: 'Sam Person',
        birthMonth: 1,
        birthDay: 2,
        calendarSystem: CalendarSystem.gregorian,
        createdAt: now,
        updatedAt: now,
      ),
    );
    placeRepository.items.add(
      Place(
        id: 'p1',
        name: 'Sam Place',
        kind: PlaceGeometryKind.point,
        points: const [GeoPoint(latitude: 1, longitude: 2)],
        createdAt: now,
        updatedAt: now,
      ),
    );

    final results = await usecase('sam');

    expect(results.devices, hasLength(1));
    expect(results.birthdays, hasLength(1));
    expect(results.places, hasLength(1));
  });
}
