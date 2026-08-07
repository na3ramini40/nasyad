import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/sync_outbox_table.dart';
import 'package:nasyad/data/sync/sync_payload_codec.dart';
import 'package:nasyad/domain/sync/sync_entity_kind.dart';
import 'package:nasyad/domain/sync/sync_mutation.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutboxTable])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.db);

  Future<List<SyncMutation>> pendingMutations() async {
    final rows =
        await (select(syncOutboxTable)
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    return rows.map(_rowToMutation).toList(growable: false);
  }

  Future<int> pendingCount() async {
    final countExp = syncOutboxTable.id.count();
    final query = selectOnly(syncOutboxTable)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final countExp = syncOutboxTable.id.count();
    final query = selectOnly(syncOutboxTable)..addColumns([countExp]);
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  Future<void> enqueue(SyncMutation mutation) {
    return into(syncOutboxTable).insertOnConflictUpdate(
      SyncOutboxTableCompanion.insert(
        id: mutation.id,
        entityKind: mutation.entityKind.storageValue,
        operation: mutation.operation.storageValue,
        entityId: mutation.entityId,
        payloadJson: SyncPayloadCodec.encode(mutation.payload),
        createdAt: mutation.createdAt,
      ),
    );
  }

  Future<void> remove(String id) {
    return (delete(syncOutboxTable)..where((row) => row.id.equals(id))).go();
  }

  Future<void> incrementAttempt(String id) async {
    final row = await (select(
      syncOutboxTable,
    )..where((entry) => entry.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (update(syncOutboxTable)..where((entry) => entry.id.equals(id)))
        .write(
          SyncOutboxTableCompanion(
            attemptCount: Value(row.attemptCount + 1),
          ),
        );
  }

  SyncMutation _rowToMutation(SyncOutboxTableData row) {
    return SyncMutation(
      id: row.id,
      entityKind: SyncEntityKind.fromStorage(row.entityKind),
      operation: SyncOperation.fromStorage(row.operation),
      entityId: row.entityId,
      payload: SyncPayloadCodec.decode(row.payloadJson),
      createdAt: row.createdAt,
    );
  }
}
