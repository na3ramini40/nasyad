import 'package:nasyad/domain/entities/birthday.dart';

abstract class BirthdayRepository {
  Stream<List<Birthday>> watchBirthdays();

  Future<List<Birthday>> getAllBirthdays();

  Future<Birthday?> getBirthday(String id);

  Future<void> createBirthday(Birthday birthday);

  Future<void> updateBirthday(Birthday birthday);

  Future<void> upsertBirthday(Birthday birthday);

  Future<void> deleteBirthday(String id);

  Future<List<Birthday>> searchBirthdaysByName(String query);
}
