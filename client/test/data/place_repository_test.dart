import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/datasources/place_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/models/place_model.dart';
import 'package:nasyad/data/repositories/place_repository_impl.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';

import '../sqlite_test_setup.dart';

void main() {
  setUpAll(setupSqliteForTests);

  late AppDatabase db;
  late PlaceRepositoryImpl places;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    places = PlaceRepositoryImpl(PlaceLocalDataSourceImpl(db.placeDao));
  });

  tearDown(() async {
    await db.close();
  });

  test('create and watch place round-trips geometry', () async {
    final now = DateTime.utc(2026, 1, 1);
    final place = Place(
      id: 'place-1',
      name: 'Office',
      kind: PlaceGeometryKind.line,
      points: const [
        GeoPoint(latitude: 35.7, longitude: 51.4),
        GeoPoint(latitude: 35.71, longitude: 51.41),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await places.createPlace(place);

    final watched = await places.watchPlaces().first.timeout(
      const Duration(seconds: 2),
    );
    expect(watched, hasLength(1));
    expect(watched.single.name, 'Office');
    expect(watched.single.kind, PlaceGeometryKind.line);
    expect(watched.single.points, place.points);

    final fetched = await places.getPlace('place-1');
    expect(fetched?.id, place.id);
    expect(fetched?.name, place.name);
    expect(fetched?.kind, place.kind);
    expect(fetched?.points, place.points);

    final search = await places.searchPlacesByName('off');
    expect(search, hasLength(1));
  });

  test('PlaceModel encodes and decodes points json', () {
    const points = [
      GeoPoint(latitude: 1.5, longitude: 2.5),
      GeoPoint(latitude: -3.0, longitude: 4.25),
    ];
    final json = PlaceModel.encodePoints(points);
    expect(PlaceModel.decodePoints(json), points);
  });
}
