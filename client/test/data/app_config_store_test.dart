import 'package:flutter_test/flutter_test.dart';

import 'package:nasyad/data/local/app_config_store.dart';
import 'package:nasyad/domain/app_config_keys.dart';
import 'package:nasyad/domain/entities/app_config_snapshot.dart';

void main() {
  group('AppConfigStore', () {
    test('memory write/read round-trip', () async {
      final store = AppConfigStore.memory();
      expect(await store.read(), isNull);

      final snapshot = AppConfigSnapshot(
        features: const {AppConfigKeys.exampleRemoteFlag: true},
        updatedAt: DateTime.utc(2026, 8, 8, 12),
        fetchedAt: DateTime.utc(2026, 8, 8, 12, 1),
      );
      await store.write(snapshot);

      final read = await store.read();
      expect(read, isNotNull);
      expect(read!.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      expect(read.isEnabled('missing_key'), isFalse);
      expect(read.updatedAt, DateTime.utc(2026, 8, 8, 12));
      expect(read.fetchedAt, DateTime.utc(2026, 8, 8, 12, 1));
    });

    test('memory initial snapshot is returned', () async {
      final store = AppConfigStore.memory(
        initial: const AppConfigSnapshot(
          features: {AppConfigKeys.exampleRemoteFlag: true},
        ),
      );
      expect(
        (await store.read())!.isEnabled(AppConfigKeys.exampleRemoteFlag),
        isTrue,
      );
    });

    test('encode/decode round-trip and defaults missing keys to false', () {
      final encoded = AppConfigStore.encode(
        AppConfigSnapshot(
          features: const {AppConfigKeys.exampleRemoteFlag: true},
          updatedAt: DateTime.utc(2026, 8, 8, 12),
          fetchedAt: DateTime.utc(2026, 8, 8, 12, 1),
        ),
      );
      final decoded = AppConfigStore.decode(encoded)!;
      expect(decoded.isEnabled(AppConfigKeys.exampleRemoteFlag), isTrue);
      expect(decoded.isEnabled('unknown_flag'), isFalse);
      expect(decoded.updatedAt, DateTime.utc(2026, 8, 8, 12));
    });

    test('decode ignores corrupt or empty input', () {
      expect(AppConfigStore.decode(null), isNull);
      expect(AppConfigStore.decode(''), isNull);
      expect(AppConfigStore.decode('not-json'), isNull);
      expect(AppConfigStore.decode('[]'), isNull);
    });
  });
}
