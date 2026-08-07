import 'package:drift/drift.dart';
import 'package:nasyad/data/local/db/app_database.dart';
import 'package:nasyad/domain/entities/birthday.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';

class BirthdayModel {
  final String id;
  final String name;
  final int birthMonth;
  final int birthDay;
  final CalendarSystem calendarSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BirthdayModel({
    required this.id,
    required this.name,
    required this.birthMonth,
    required this.birthDay,
    required this.calendarSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  Birthday toEntity() {
    return Birthday(
      id: id,
      name: name,
      birthMonth: birthMonth,
      birthDay: birthDay,
      calendarSystem: calendarSystem,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BirthdayModel.fromEntity(Birthday birthday) {
    return BirthdayModel(
      id: birthday.id,
      name: birthday.name,
      birthMonth: birthday.birthMonth,
      birthDay: birthday.birthDay,
      calendarSystem: birthday.calendarSystem,
      createdAt: birthday.createdAt,
      updatedAt: birthday.updatedAt,
    );
  }

  factory BirthdayModel.fromRow(BirthdaysTableData row) {
    return BirthdayModel(
      id: row.id,
      name: row.name,
      birthMonth: row.birthMonth,
      birthDay: row.birthDay,
      calendarSystem: CalendarSystem.fromStorage(row.calendarSystem),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  BirthdaysTableCompanion toInsertCompanion() {
    return BirthdaysTableCompanion.insert(
      id: id,
      name: name,
      birthMonth: birthMonth,
      birthDay: birthDay,
      calendarSystem: Value(calendarSystem.storageValue),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  BirthdaysTableData toRow() {
    return BirthdaysTableData(
      id: id,
      name: name,
      birthMonth: birthMonth,
      birthDay: birthDay,
      calendarSystem: calendarSystem.storageValue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Snake_case wire shape matching server [BirthdaySerializer].
  Map<String, dynamic> toSyncJson() => {
    'id': id,
    'name': name,
    'birth_month': birthMonth,
    'birth_day': birthDay,
    'calendar_system': calendarSystem.storageValue,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory BirthdayModel.fromSyncJson(Map<String, dynamic> json) {
    return BirthdayModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthMonth: (json['birth_month'] as num).toInt(),
      birthDay: (json['birth_day'] as num).toInt(),
      calendarSystem: CalendarSystem.fromStorage(
        json['calendar_system'] as String?,
      ),
      createdAt:
          _parseBirthdayIso(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt:
          _parseBirthdayIso(json['updated_at']) ?? DateTime.now().toUtc(),
    );
  }
}

DateTime? _parseBirthdayIso(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toUtc();
}
