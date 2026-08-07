// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_log_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $DevicesTableTable get devicesTable => attachedDatabase.devicesTable;
  $DeviceLogsTableTable get deviceLogsTable => attachedDatabase.deviceLogsTable;
  DeviceLogDaoManager get managers => DeviceLogDaoManager(this);
}

class DeviceLogDaoManager {
  final _$DeviceLogDaoMixin _db;
  DeviceLogDaoManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db.attachedDatabase, _db.devicesTable);
  $$DeviceLogsTableTableTableManager get deviceLogsTable =>
      $$DeviceLogsTableTableTableManager(
        _db.attachedDatabase,
        _db.deviceLogsTable,
      );
}
