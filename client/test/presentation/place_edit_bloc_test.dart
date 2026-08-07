import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/entities/geo_point.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/entities/place_geometry_kind.dart';
import 'package:nasyad/domain/usecases/place/create_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/delete_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/get_place_usecase.dart';
import 'package:nasyad/domain/usecases/place/update_place_usecase.dart';
import 'package:nasyad/presentation/place/bloc/place_edit_bloc.dart';

import '../helpers/fake_repositories.dart';

const _point = GeoPoint(latitude: 35.6892, longitude: 51.3890);
const _point2 = GeoPoint(latitude: 35.7, longitude: 51.4);

Place _sample({String id = 'p1', String name = 'Park'}) {
  final now = DateTime(2026, 1, 1);
  return Place(
    id: id,
    name: name,
    kind: PlaceGeometryKind.point,
    points: const [_point],
    createdAt: now,
    updatedAt: now,
  );
}

const _saveMessages = PlaceEditSaveRequested(
  nameRequiredMessage: 'name required',
  geometryRequiredMessage: 'geometry required',
);

PlaceEditBloc _build(FakePlaceRepository repo, {String? placeId}) {
  return PlaceEditBloc(
    placeId: placeId,
    getPlace: GetPlaceUsecase(repo),
    createPlace: CreatePlaceUsecase(repo),
    updatePlace: UpdatePlaceUsecase(repo),
    deletePlace: DeletePlaceUsecase(repo),
  );
}

void main() {
  late FakePlaceRepository repository;

  setUp(() {
    repository = FakePlaceRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  group('adding places', () {
    test('creates point place after map tap and save', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(const PlaceEditStarted());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const PlaceEditNameChanged('Tehran pin'));
      bloc.add(const PlaceEditMapTapped(_point));
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>().having(
            (s) => s.status,
            'status',
            PlaceEditStatus.saved,
          ),
        ),
      );
      expect(repository.items, hasLength(1));
      expect(repository.items.first.name, 'Tehran pin');
      expect(repository.items.first.kind, PlaceGeometryKind.point);
      expect(repository.items.first.points, [_point]);
    });

    test('rejects save when name empty', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(const PlaceEditStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PlaceEditMapTapped(_point));
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>()
              .having((s) => s.status, 'status', PlaceEditStatus.ready)
              .having((s) => s.errorMessage, 'error', 'name required'),
        ),
      );
      expect(repository.items, isEmpty);
    });

    test('rejects save when geometry incomplete', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(const PlaceEditStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PlaceEditNameChanged('Path'));
      bloc.add(const PlaceEditKindChanged(PlaceGeometryKind.line));
      bloc.add(const PlaceEditMapTapped(_point));
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>()
              .having((s) => s.status, 'status', PlaceEditStatus.ready)
              .having((s) => s.errorMessage, 'error', 'geometry required'),
        ),
      );
      expect(repository.items, isEmpty);
    });

    test('map tap replaces point for point geometry', () async {
      final bloc = _build(repository);
      addTearDown(bloc.close);

      bloc.add(const PlaceEditStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PlaceEditMapTapped(_point));
      bloc.add(const PlaceEditMapTapped(_point2));

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>().having((s) => s.points, 'points', [_point2]),
        ),
      );
    });
  });

  group('editing places', () {
    test('loads existing place and updates name', () async {
      repository.items.add(_sample(id: 'p1', name: 'Park'));

      final bloc = _build(repository, placeId: 'p1');
      addTearDown(bloc.close);

      bloc.add(const PlaceEditStarted());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>()
              .having((s) => s.status, 'status', PlaceEditStatus.ready)
              .having((s) => s.name, 'name', 'Park'),
        ),
      );

      bloc.add(const PlaceEditNameChanged('Park Updated'));
      bloc.add(_saveMessages);

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>().having(
            (s) => s.status,
            'status',
            PlaceEditStatus.saved,
          ),
        ),
      );
      expect(repository.items.single.name, 'Park Updated');
    });

    test('deletes existing place', () async {
      repository.items.add(_sample(id: 'p1'));

      final bloc = _build(repository, placeId: 'p1');
      addTearDown(bloc.close);

      bloc.add(const PlaceEditStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const PlaceEditDeleteRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<PlaceEditState>().having(
            (s) => s.status,
            'status',
            PlaceEditStatus.deleted,
          ),
        ),
      );
      expect(repository.items, isEmpty);
    });
  });
}
