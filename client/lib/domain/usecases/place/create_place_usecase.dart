import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/repositories/place_repository.dart';

class CreatePlaceUsecase {
  CreatePlaceUsecase(this._repository);

  final PlaceRepository _repository;

  Future<void> call(Place place) => _repository.createPlace(place);
}
