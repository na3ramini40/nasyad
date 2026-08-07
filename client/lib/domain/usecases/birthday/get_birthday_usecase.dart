import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';

class GetBirthdayUsecase {
  final BirthdayRepository _repository;

  GetBirthdayUsecase(this._repository);

  Future<Birthday?> call(String id) => _repository.getBirthday(id);
}
