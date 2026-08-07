import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/repositories/place_repository.dart';

class WatchPlacesUsecase {
  WatchPlacesUsecase(this._repository);

  final PlaceRepository _repository;

  Stream<List<Place>> call() => _repository.watchPlaces();
}
