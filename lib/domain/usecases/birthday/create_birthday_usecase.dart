import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/services/month_day.dart';

class CreateBirthdayUsecase {
  final BirthdayRepository _repository;

  CreateBirthdayUsecase(this._repository);

  Future<void> call(Birthday birthday) {
    if (birthday.name.trim().isEmpty) {
      throw ArgumentError('Name is required');
    }
    MonthDay.validate(
      birthday.birthMonth,
      birthday.birthDay,
      birthday.calendarSystem,
    );
    return _repository.createBirthday(
      birthday.copyWith(name: birthday.name.trim()),
    );
  }
}
