import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';

/// Orchestrates local-first writes: Drift is authoritative for reads;
/// mutations enqueue to outbox and flush to [RemoteSyncPort] when online.
abstract class LocalFirstSyncCoordinator {
  Future<void> recordDeviceUpsert(Device device);

  Future<void> recordDeviceUpserts(Iterable<Device> devices);

  Future<void> recordDeviceLogUpsert(DeviceLog log);

  Future<void> recordDeviceLogDelete(String id);

  Future<void> recordBirthdayUpsert(Birthday birthday);

  Future<void> recordBirthdayDelete(String id);

  Future<SyncResult> flushOutbox();

  Future<SyncResult> pullRemote();

  Future<SyncResult> sync();

  Stream<SyncStatus> watchStatus();
}
