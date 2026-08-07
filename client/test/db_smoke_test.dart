import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/app_services.dart';
import 'package:nasyad/core/version/last_seen_version_store.dart';
import 'package:nasyad/data/local/db/app_database.dart';

import 'sqlite_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(setupSqliteForTests);

  test('watchDeviceSummaries emits empty list', () async {
    final services = await AppServices.createForTests(
      AppDatabase(NativeDatabase.memory()),
      lastSeenVersionStore: LastSeenVersionStore.memory(),
    );
    addTearDown(services.dispose);

    final first = await services.watchDeviceSummaries().first.timeout(
      const Duration(seconds: 2),
    );
    expect(first, isEmpty);
  });
}
