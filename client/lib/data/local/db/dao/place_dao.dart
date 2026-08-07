import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/places_table.dart';

part 'place_dao.g.dart';

@DriftAccessor(tables: [PlacesTable])
class PlaceDao extends DatabaseAccessor<AppDatabase> with _$PlaceDaoMixin {
  PlaceDao(super.db);

  Stream<List<PlacesTableData>> watchAll() {
    return (select(
      placesTable,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  Future<List<PlacesTableData>> getAll() {
    return (select(
      placesTable,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
  }

  Future<PlacesTableData?> getById(String id) {
    return (select(
      placesTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertPlace(PlacesTableCompanion place) {
    return into(placesTable).insert(place);
  }

  Future<int> upsertPlace(PlacesTableCompanion place) {
    return into(placesTable).insertOnConflictUpdate(place);
  }

  Future<bool> replacePlace(PlacesTableData place) {
    return update(placesTable).replace(place);
  }

  Future<int> deleteById(String id) {
    return (delete(placesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<List<PlacesTableData>> searchByName(String query) {
    final pattern = _likePattern(query);
    return (select(placesTable)
          ..where((t) => t.name.like(pattern))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  String _likePattern(String query) {
    final escaped = query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return '%$escaped%';
  }
}
