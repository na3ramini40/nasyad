import 'package:nasyad/domain/entities/place.dart';

abstract class PlaceRepository {
  Stream<List<Place>> watchPlaces();

  Future<List<Place>> getAllPlaces();

  Future<Place?> getPlace(String id);

  Future<void> createPlace(Place place);

  Future<void> updatePlace(Place place);

  Future<void> upsertPlace(Place place);

  Future<void> deletePlace(String id);

  Future<List<Place>> searchPlacesByName(String query);
}
