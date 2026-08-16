import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:nasyad/domain/entities/calendar_system.dart';

/// Formats a full [DateTime] using the user's calendar preference and locale.
String formatPreferredDateTime(
  DateTime date, {
  required CalendarSystem calendar,
  required Locale locale,
}) {
  final local = date.toLocal();
  final time = DateFormat.jm(locale.toString()).format(local);
  if (calendar == CalendarSystem.persian) {
    final j = Jalali.fromDateTime(local);
    final month = j.month.toString().padLeft(2, '0');
    final day = j.day.toString().padLeft(2, '0');
    return '${j.year}/$month/$day $time';
  }
  return '${DateFormat.yMMMd(locale.toString()).format(local)} $time';
}
