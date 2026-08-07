import 'package:nasyad/data/datasources/birthday_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/birthday_dao.dart';
import 'package:nasyad/data/models/birthday_model.dart';

class BirthdayLocalDataSourceImpl implements BirthdayLocalDataSource {
  BirthdayLocalDataSourceImpl(this._dao);

  final BirthdayDao _dao;

  @override
  Stream<List<BirthdayModel>> watchBirthdays() {
    return _dao.watchAll().map(
      (rows) => rows.map(BirthdayModel.fromRow).toList(growable: false),
    );
  }

  @override
  Future<BirthdayModel?> getBirthday(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : BirthdayModel.fromRow(row);
  }

  @override
  Future<void> insertBirthday(BirthdayModel birthday) {
    return _dao.insertBirthday(birthday.toInsertCompanion());
  }

  @override
  Future<void> updateBirthday(BirthdayModel birthday) {
    return _dao.replaceBirthday(birthday.toRow());
  }

  @override
  Future<void> deleteBirthday(String id) {
    return _dao.deleteById(id);
  }

  @override
  Future<List<BirthdayModel>> searchBirthdaysByName(String query) async {
    final rows = await _dao.searchByName(query);
    return rows.map(BirthdayModel.fromRow).toList(growable: false);
  }
}
