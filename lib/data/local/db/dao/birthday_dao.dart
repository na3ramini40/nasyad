import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/birthdays_table.dart';

part 'birthday_dao.g.dart';

@DriftAccessor(tables: [BirthdaysTable])
class BirthdayDao extends DatabaseAccessor<AppDatabase>
    with _$BirthdayDaoMixin {
  BirthdayDao(super.db);

  Stream<List<BirthdaysTableData>> watchAll() {
    return (select(
      birthdaysTable,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<BirthdaysTableData?> getById(String id) {
    return (select(
      birthdaysTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertBirthday(BirthdaysTableCompanion birthday) {
    return into(birthdaysTable).insert(birthday);
  }

  Future<bool> replaceBirthday(BirthdaysTableData birthday) {
    return update(birthdaysTable).replace(birthday);
  }

  Future<int> deleteById(String id) {
    return (delete(birthdaysTable)..where((t) => t.id.equals(id))).go();
  }
}
