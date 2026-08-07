import 'package:nasyad/data/local/db/dao/sync_outbox_dao.dart';
import 'package:nasyad/data/sync/local_sync_applier.dart';
import 'package:nasyad/data/sync/sync_payload_codec.dart';
import 'package:nasyad/data/sync/sync_state_store.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/device.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/sync/local_first_sync_coordinator.dart';
import 'package:nasyad/domain/sync/remote_sync_port.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';

class LocalFirstSyncCoordinatorImpl implements LocalFirstSyncCoordinator {
  LocalFirstSyncCoordinatorImpl({
    required SyncOutboxDao outbox,
    required RemoteSyncPort remote,
    required LocalSyncApplier applier,
    SyncStateStore? stateStore,
  }) : _outbox = outbox,
       _remote = remote,
       _applier = applier,
       _stateStore = stateStore ?? SyncStateStore();

  final SyncOutboxDao _outbox;
  final RemoteSyncPort _remote;
  final LocalSyncApplier _applier;
  final SyncStateStore _stateStore;

  @override
  Future<void> recordDeviceUpsert(Device device) {
    return _enqueue(SyncPayloadCodec.deviceUpsert(device));
  }

  @override
  Future<void> recordDeviceUpserts(Iterable<Device> devices) async {
    for (final device in devices) {
      await recordDeviceUpsert(device);
    }
  }

  @override
  Future<void> recordDeviceLogUpsert(DeviceLog log) {
    return _enqueue(SyncPayloadCodec.deviceLogUpsert(log));
  }

  @override
  Future<void> recordDeviceLogDelete(String id) {
    return _enqueue(SyncPayloadCodec.deviceLogDelete(id));
  }

  @override
  Future<void> recordBirthdayUpsert(Birthday birthday) {
    return _enqueue(SyncPayloadCodec.birthdayUpsert(birthday));
  }

  @override
  Future<void> recordBirthdayDelete(String id) {
    return _enqueue(SyncPayloadCodec.birthdayDelete(id));
  }

  @override
  Future<SyncResult> flushOutbox() async {
    if (!await _remote.isConfigured() || !await _remote.isAuthenticated()) {
      return const SyncResult.idle();
    }

    final pending = await _outbox.pendingMutations();
    var pushed = 0;
    var failed = 0;
    final errors = <String>[];

    for (final mutation in pending) {
      try {
        await _remote.pushMutation(mutation);
        await _outbox.remove(mutation.id);
        pushed++;
      } catch (error) {
        failed++;
        errors.add('$error');
        await _outbox.incrementAttempt(mutation.id);
      }
    }

    return SyncResult(
      pushedCount: pushed,
      pulledCount: 0,
      failedCount: failed,
      errors: errors,
    );
  }

  @override
  Future<SyncResult> pullRemote() async {
    if (!await _remote.isConfigured() || !await _remote.isAuthenticated()) {
      return const SyncResult.idle();
    }

    final since = await _stateStore.lastPulledAt();
    final remoteChanges = await _remote.pullChanges(updatedSince: since);
    var pulled = 0;
    var failed = 0;
    final errors = <String>[];

    for (final mutation in remoteChanges) {
      try {
        await _applier.apply(mutation);
        pulled++;
      } catch (error) {
        failed++;
        errors.add('$error');
      }
    }

    final now = DateTime.now();
    await _stateStore.setLastPulledAt(now);
    await _stateStore.setLastSyncedAt(now);

    return SyncResult(
      pushedCount: 0,
      pulledCount: pulled,
      failedCount: failed,
      errors: errors,
    );
  }

  @override
  Future<SyncResult> sync() async {
    final pushResult = await flushOutbox();
    final pullResult = await pullRemote();
    return SyncResult(
      pushedCount: pushResult.pushedCount,
      pulledCount: pullResult.pulledCount,
      failedCount: pushResult.failedCount + pullResult.failedCount,
      errors: [...pushResult.errors, ...pullResult.errors],
    );
  }

  @override
  Stream<SyncStatus> watchStatus() async* {
    yield await _currentStatus();
    yield* _outbox.watchPendingCount().asyncMap((_) => _currentStatus());
  }

  Future<void> _enqueue(SyncMutation mutation) async {
    await _outbox.enqueue(mutation);
  }

  Future<SyncStatus> _currentStatus() async {
    return SyncStatus(
      pendingCount: await _outbox.pendingCount(),
      lastSyncedAt: await _stateStore.lastSyncedAt(),
      remoteConfigured: await _remote.isConfigured(),
      remoteAuthenticated: await _remote.isAuthenticated(),
    );
  }
}
