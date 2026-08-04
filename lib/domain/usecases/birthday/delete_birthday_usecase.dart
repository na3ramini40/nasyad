import 'package:nasyad/domain/repositories/birthday_repository.dart';

class DeleteBirthdayUsecase {
  final BirthdayRepository _repository;

  DeleteBirthdayUsecase(this._repository);

  Future<void> call(String id) => _repository.deleteBirthday(id);
}
