// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_outbox_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncOutboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncOutboxTableTable get syncOutboxTable => attachedDatabase.syncOutboxTable;
  SyncOutboxDaoManager get managers => SyncOutboxDaoManager(this);
}

class SyncOutboxDaoManager {
  final _$SyncOutboxDaoMixin _db;
  SyncOutboxDaoManager(this._db);
  $$SyncOutboxTableTableTableManager get syncOutboxTable =>
      $$SyncOutboxTableTableTableManager(
        _db.attachedDatabase,
        _db.syncOutboxTable,
      );
}
