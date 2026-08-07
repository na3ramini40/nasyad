// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceDaoMixin on DatabaseAccessor<AppDatabase> {
  $DevicesTableTable get devicesTable => attachedDatabase.devicesTable;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db.attachedDatabase, _db.devicesTable);
}
