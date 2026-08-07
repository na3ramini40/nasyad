import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';
import 'package:nasyad/domain/sync/local_first_sync_coordinator.dart';

class LocalFirstBirthdayRepository implements BirthdayRepository {
  LocalFirstBirthdayRepository({
    required BirthdayRepository local,
    required LocalFirstSyncCoordinator syncCoordinator,
  }) : _local = local,
       _syncCoordinator = syncCoordinator;

  final BirthdayRepository _local;
  final LocalFirstSyncCoordinator _syncCoordinator;

  @override
  Stream<List<Birthday>> watchBirthdays() => _local.watchBirthdays();

  @override
  Future<Birthday?> getBirthday(String id) => _local.getBirthday(id);

  @override
  Future<void> createBirthday(Birthday birthday) async {
    await _local.createBirthday(birthday);
    await _syncCoordinator.recordBirthdayUpsert(birthday);
  }

  @override
  Future<void> updateBirthday(Birthday birthday) async {
    await _local.updateBirthday(birthday);
    await _syncCoordinator.recordBirthdayUpsert(birthday);
  }

  @override
  Future<void> deleteBirthday(String id) async {
    await _local.deleteBirthday(id);
    await _syncCoordinator.recordBirthdayDelete(id);
  }

  @override
  Future<List<Birthday>> searchBirthdaysByName(String query) =>
      _local.searchBirthdaysByName(query);
}
