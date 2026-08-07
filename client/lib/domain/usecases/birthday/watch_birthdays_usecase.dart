import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';

class WatchBirthdaysUsecase {
  final BirthdayRepository _repository;

  WatchBirthdaysUsecase(this._repository);

  Stream<List<Birthday>> call() => _repository.watchBirthdays();
}
