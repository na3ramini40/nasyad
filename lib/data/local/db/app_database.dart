import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/tables/device_logs_table.dart';
import 'package:nasyad/data/local/db/tables/devices_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [DevicesTable, DeviceLogsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
