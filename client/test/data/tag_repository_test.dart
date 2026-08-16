import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/data/datasources/tag_local_datasource_impl.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/repositories/tag_repository_impl.dart';
import 'package:nasyad/domain/entities/tag.dart';

import '../sqlite_test_setup.dart';

void main() {
  setUpAll(setupSqliteForTests);

  late AppDatabase db;
  late TagRepositoryImpl tags;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    tags = TagRepositoryImpl(TagLocalDataSourceImpl(db.tagDao));
  });

  tearDown(() async {
    await db.close();
  });

  test('tag CRUD and device assignment round-trip', () async {
    final now = DateTime.utc(2026, 1, 1);
    final garage = Tag(
      id: 'tag-1',
      name: 'Garage',
      createdAt: now,
      updatedAt: now,
    );
    final kitchen = Tag(
      id: 'tag-2',
      name: 'Kitchen',
      createdAt: now,
      updatedAt: now,
    );

    await tags.createTag(garage);
    await tags.createTag(kitchen);
    await tags.setDeviceTags('device-1', ['tag-1', 'tag-2']);

    final watched = await tags.watchTags().first.timeout(
      const Duration(seconds: 2),
    );
    expect(watched.map((t) => t.name), ['Garage', 'Kitchen']);

    final forDevice = await tags.getTagsForDevice('device-1');
    expect(forDevice.map((t) => t.id), ['tag-1', 'tag-2']);

    await tags.updateTag(
      garage.copyWith(
        name: 'Workshop',
        updatedAt: now.add(const Duration(days: 1)),
      ),
    );
    expect((await tags.getTag('tag-1'))?.name, 'Workshop');

    await tags.setDeviceTags('device-1', ['tag-2']);
    expect((await tags.getTagsForDevice('device-1')).single.id, 'tag-2');

    await tags.deleteTag('tag-2');
    expect(await tags.getTag('tag-2'), isNull);
    expect(await tags.getTagsForDevice('device-1'), isEmpty);
  });
}
