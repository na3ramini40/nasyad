// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_dao.dart';

// ignore_for_file: type=lint
mixin _$PlaceDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlacesTableTable get placesTable => attachedDatabase.placesTable;
  PlaceDaoManager get managers => PlaceDaoManager(this);
}

class PlaceDaoManager {
  final _$PlaceDaoMixin _db;
  PlaceDaoManager(this._db);
  $$PlacesTableTableTableManager get placesTable =>
      $$PlacesTableTableTableManager(_db.attachedDatabase, _db.placesTable);
}
