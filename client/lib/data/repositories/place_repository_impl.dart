import 'package:nasyad/data/datasources/place_local_datasource.dart';
import 'package:nasyad/data/models/place_model.dart';
import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/repositories/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  PlaceRepositoryImpl(this._source);

  final PlaceLocalDataSource _source;

  @override
  Stream<List<Place>> watchPlaces() {
    return _source.watchPlaces().map(
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<List<Place>> getAllPlaces() async {
    final models = await _source.getAllPlaces();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<Place?> getPlace(String id) async {
    return (await _source.getPlace(id))?.toEntity();
  }

  @override
  Future<void> createPlace(Place place) {
    return _source.insertPlace(PlaceModel.fromEntity(place));
  }

  @override
  Future<void> updatePlace(Place place) {
    return _source.updatePlace(PlaceModel.fromEntity(place));
  }

  @override
  Future<void> upsertPlace(Place place) {
    return _source.upsertPlace(PlaceModel.fromEntity(place));
  }

  @override
  Future<void> deletePlace(String id) {
    return _source.deletePlace(id);
  }

  @override
  Future<List<Place>> searchPlacesByName(String query) async {
    final models = await _source.searchPlacesByName(query);
    return models.map((m) => m.toEntity()).toList(growable: false);
  }
}
