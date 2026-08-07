import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/domain/usecases/place/delete_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/watch_places_usecase.dart';
import 'package:nasyad/presentation/place/bloc/place_list_bloc.dart';

import '../helpers/fake_repositories.dart';

Place _sample({String id = 'p1', String name = 'Home'}) {
  final now = DateTime(2026, 1, 1);
  return Place(
    id: id,
    name: name,
    kind: PlaceGeometryKind.point,
    points: const [GeoPoint(latitude: 35.7, longitude: 51.4)],
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('PlaceListBloc', () {
    late FakePlaceRepository repository;
    late PlaceListBloc bloc;

    setUp(() {
      repository = FakePlaceRepository();
      bloc = PlaceListBloc(
        watchPlaces: WatchPlacesUsecase(repository),
        deletePlace: DeletePlaceUsecase(repository),
      );
    });

    tearDown(() async {
      await bloc.close();
      await repository.dispose();
    });

    test('loads places from watch', () async {
      expectLater(
        bloc.stream,
        emitsInOrder([
          const PlaceListLoading(),
          isA<PlaceListLoaded>().having(
            (s) => s.places,
            'places',
            hasLength(1),
          ),
        ]),
      );

      bloc.add(const PlaceListStarted());
      await Future<void>.delayed(Duration.zero);
      repository.items.add(_sample());
      repository.emit();
    });

    test('deletes place by id', () async {
      repository.items.add(_sample(id: 'p1'));
      bloc.add(const PlaceListStarted());
      await Future<void>.delayed(Duration.zero);
      repository.emit();

      bloc.add(const PlaceListDeleteRequested('p1'));
      await Future<void>.delayed(Duration.zero);

      expect(repository.items, isEmpty);
    });
  });
}
