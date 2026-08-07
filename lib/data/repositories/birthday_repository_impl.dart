import 'package:nasyad/data/datasources/birthday_local_datasource.dart';
import 'package:nasyad/data/models/birthday_model.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/repositories/birthday_repository.dart';

class BirthdayRepositoryImpl implements BirthdayRepository {
  BirthdayRepositoryImpl(this._source);

  final BirthdayLocalDataSource _source;

  @override
  Stream<List<Birthday>> watchBirthdays() {
    return _source.watchBirthdays().map(
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<Birthday?> getBirthday(String id) async {
    return (await _source.getBirthday(id))?.toEntity();
  }

  @override
  Future<void> createBirthday(Birthday birthday) {
    return _source.insertBirthday(BirthdayModel.fromEntity(birthday));
  }

  @override
  Future<void> updateBirthday(Birthday birthday) {
    return _source.updateBirthday(BirthdayModel.fromEntity(birthday));
  }

  @override
  Future<void> deleteBirthday(String id) {
    return _source.deleteBirthday(id);
  }

  @override
  Future<List<Birthday>> searchBirthdaysByName(String query) async {
    final models = await _source.searchBirthdaysByName(query);
    return models.map((m) => m.toEntity()).toList(growable: false);
  }
}
