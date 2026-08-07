import 'package:nasyad/domain/repositories/place_repository.dart';

class DeletePlaceUsecase {
  DeletePlaceUsecase(this._repository);

  final PlaceRepository _repository;

  Future<void> call(String id) => _repository.deletePlace(id);
}
