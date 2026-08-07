import 'package:nasyad/domain/entities/place.dart';
import 'package:nasyad/domain/repositories/place_repository.dart';

class GetPlaceUsecase {
  GetPlaceUsecase(this._repository);

  final PlaceRepository _repository;

  Future<Place?> call(String id) => _repository.getPlace(id);
}
