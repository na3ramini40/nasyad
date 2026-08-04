// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'birthday_dao.dart';

// ignore_for_file: type=lint
mixin _$BirthdayDaoMixin on DatabaseAccessor<AppDatabase> {
  $BirthdaysTableTable get birthdaysTable => attachedDatabase.birthdaysTable;
  BirthdayDaoManager get managers => BirthdayDaoManager(this);
}

class BirthdayDaoManager {
  final _$BirthdayDaoMixin _db;
  BirthdayDaoManager(this._db);
  $$BirthdaysTableTableTableManager get birthdaysTable =>
      $$BirthdaysTableTableTableManager(
        _db.attachedDatabase,
        _db.birthdaysTable,
      );
}
