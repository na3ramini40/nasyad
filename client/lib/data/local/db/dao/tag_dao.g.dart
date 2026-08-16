// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_dao.dart';

// ignore_for_file: type=lint
mixin _$TagDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagsTableTable get tagsTable => attachedDatabase.tagsTable;
  $DeviceTagsTableTable get deviceTagsTable => attachedDatabase.deviceTagsTable;
  TagDaoManager get managers => TagDaoManager(this);
}

class TagDaoManager {
  final _$TagDaoMixin _db;
  TagDaoManager(this._db);
  $$TagsTableTableTableManager get tagsTable =>
      $$TagsTableTableTableManager(_db.attachedDatabase, _db.tagsTable);
  $$DeviceTagsTableTableTableManager get deviceTagsTable =>
      $$DeviceTagsTableTableTableManager(
        _db.attachedDatabase,
        _db.deviceTagsTable,
      );
}
