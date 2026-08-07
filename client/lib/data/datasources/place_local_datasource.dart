import 'package:nasyad/data/models/place_model.dart';

abstract class PlaceLocalDataSource {
  Stream<List<PlaceModel>> watchPlaces();

  Future<List<PlaceModel>> getAllPlaces();

  Future<PlaceModel?> getPlace(String id);

  Future<void> insertPlace(PlaceModel place);

  Future<void> updatePlace(PlaceModel place);

  Future<void> upsertPlace(PlaceModel place);

  Future<void> deletePlace(String id);

  Future<List<PlaceModel>> searchPlacesByName(String query);
}
