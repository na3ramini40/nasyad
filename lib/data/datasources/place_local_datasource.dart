import 'package:nasyad/data/models/place_model.dart';

abstract class PlaceLocalDataSource {
  Stream<List<PlaceModel>> watchPlaces();

  Future<PlaceModel?> getPlace(String id);

  Future<void> insertPlace(PlaceModel place);

  Future<void> updatePlace(PlaceModel place);

  Future<void> deletePlace(String id);
}
