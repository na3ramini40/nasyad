import 'package:nasyad/data/datasources/place_local_datasource.dart';
import 'package:nasyad/data/local/db/dao/place_dao.dart';
import 'package:nasyad/data/models/place_model.dart';

class PlaceLocalDataSourceImpl implements PlaceLocalDataSource {
  PlaceLocalDataSourceImpl(this._dao);

  final PlaceDao _dao;

  @override
  Stream<List<PlaceModel>> watchPlaces() {
    return _dao.watchAll().map(
      (rows) => rows.map(PlaceModel.fromRow).toList(growable: false),
    );
  }

  @override
  Future<PlaceModel?> getPlace(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : PlaceModel.fromRow(row);
  }

  @override
  Future<void> insertPlace(PlaceModel place) {
    return _dao.insertPlace(place.toInsertCompanion());
  }

  @override
  Future<void> updatePlace(PlaceModel place) {
    return _dao.replacePlace(place.toRow());
  }

  @override
  Future<void> deletePlace(String id) {
    return _dao.deleteById(id);
  }
}
