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
}
