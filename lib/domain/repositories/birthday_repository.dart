import 'package:nasyad/domain/entities/birthday.dart';

abstract class BirthdayRepository {
  Stream<List<Birthday>> watchBirthdays();

  Future<Birthday?> getBirthday(String id);

  Future<void> createBirthday(Birthday birthday);

  Future<void> updateBirthday(Birthday birthday);

  Future<void> deleteBirthday(String id);
}
