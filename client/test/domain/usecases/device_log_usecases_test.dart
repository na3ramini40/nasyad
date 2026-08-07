import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/domain/usecases/device_log/create_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/delete_device_log_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/get_log_for_device_usecase.dart';
import 'package:nasyad/domain/usecases/device_log/watch_logs_for_device_usecase.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeDeviceLogRepository repository;

  setUp(() {
    repository = FakeDeviceLogRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  test('CreateDeviceLogUsecase delegates', () async {
    await CreateDeviceLogUsecase(repository)(sampleLog());
    expect(repository.created, hasLength(1));
  });

  test('DeleteDeviceLogUsecase delegates', () async {
    await DeleteDeviceLogUsecase(repository)('log-1');
    expect(repository.deletedIds, ['log-1']);
  });

  test('GetLogsForDeviceUsecase returns logs', () async {
    repository.logsByDevice['device-1'] = [sampleLog()];
    final logs = await GetLogsForDeviceUsecase(repository)('device-1');
    expect(logs.first.id, 'log-1');
  });

  test('WatchLogsForDeviceUsecase exposes stream', () async {
    final future = WatchLogsForDeviceUsecase(repository)('device-1').first;
    repository.emitLogs([sampleLog()]);
    expect((await future).first.id, 'log-1');
  });
}
