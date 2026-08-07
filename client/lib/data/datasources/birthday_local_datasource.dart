import 'package:nasyad/data/models/birthday_model.dart';

abstract class BirthdayLocalDataSource {
  Stream<List<BirthdayModel>> watchBirthdays();

  Future<List<BirthdayModel>> getAllBirthdays();

  Future<BirthdayModel?> getBirthday(String id);

  Future<void> insertBirthday(BirthdayModel birthday);

  Future<void> updateBirthday(BirthdayModel birthday);

  Future<void> upsertBirthday(BirthdayModel birthday);

  Future<void> deleteBirthday(String id);

  Future<List<BirthdayModel>> searchBirthdaysByName(String query);
}
