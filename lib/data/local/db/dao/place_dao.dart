import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/data/local/db/tables/places_table.dart';

part 'place_dao.g.dart';

@DriftAccessor(tables: [PlacesTable])
class PlaceDao extends DatabaseAccessor<AppDatabase> with _$PlaceDaoMixin {
  PlaceDao(super.db);

  Stream<List<PlacesTableData>> watchAll() {
    return (select(placesTable)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  Future<PlacesTableData?> getById(String id) {
    return (select(placesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertPlace(PlacesTableCompanion place) {
    return into(placesTable).insert(place);
  }

  Future<bool> replacePlace(PlacesTableData place) {
    return update(placesTable).replace(place);
  }

  Future<int> deleteById(String id) {
    return (delete(placesTable)..where((t) => t.id.equals(id))).go();
  }
}
