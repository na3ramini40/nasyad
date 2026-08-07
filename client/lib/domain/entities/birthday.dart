import 'package:equatable/equatable.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';

class Birthday extends Equatable {
  final String id;
  final String name;
  final int birthMonth;
  final int birthDay;
  final CalendarSystem calendarSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Birthday({
    required this.id,
    required this.name,
    required this.birthMonth,
    required this.birthDay,
    required this.calendarSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  Birthday copyWith({
    String? id,
    String? name,
    int? birthMonth,
    int? birthDay,
    CalendarSystem? calendarSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Birthday(
      id: id ?? this.id,
      name: name ?? this.name,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      calendarSystem: calendarSystem ?? this.calendarSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    birthMonth,
    birthDay,
    calendarSystem,
    createdAt,
    updatedAt,
  ];
}
