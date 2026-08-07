import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nasyad/domain/entities/schedule_template.dart';
import 'package:nasyad/domain/entities/schedule_type.dart';

class ScheduleTemplateCatalogException implements Exception {
  ScheduleTemplateCatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class ScheduleTemplateCatalog {
  static const assetPath = 'lib/core/data/schedule_templates.json';

  static List<ScheduleTemplate>? _cache;

  static Future<List<ScheduleTemplate>> load() async {
    if (_cache != null) return _cache!;
    final json = await rootBundle.loadString(assetPath);
    _cache = parse(json);
    return _cache!;
  }

  static List<ScheduleTemplate> parse(String json) {
    final dynamic raw;
    try {
      raw = jsonDecode(json);
    } on FormatException catch (error) {
      throw ScheduleTemplateCatalogException('Invalid JSON: ${error.message}');
    }

    if (raw is! Map<String, dynamic>) {
      throw ScheduleTemplateCatalogException('JSON root must be an object');
    }

    final templatesRaw = raw['templates'];
    if (templatesRaw is! List<dynamic>) {
      throw ScheduleTemplateCatalogException('templates must be an array');
    }

    return templatesRaw.map(_parseTemplate).toList(growable: false);
  }

  static ScheduleTemplate _parseTemplate(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw ScheduleTemplateCatalogException('Each template must be an object');
    }

    final id = raw['id']?.toString();
    if (id == null || id.isEmpty) {
      throw ScheduleTemplateCatalogException('Template id is required');
    }

    final labelRaw = raw['label'];
    if (labelRaw is! Map<String, dynamic>) {
      throw ScheduleTemplateCatalogException(
        'Template $id label must be an object',
      );
    }

    final labelEn = labelRaw['en']?.toString();
    final labelFa = labelRaw['fa']?.toString();
    if (labelEn == null ||
        labelEn.isEmpty ||
        labelFa == null ||
        labelFa.isEmpty) {
      throw ScheduleTemplateCatalogException(
        'Template $id requires en and fa labels',
      );
    }

    final scheduleTypeRaw = raw['scheduleType']?.toString();
    if (scheduleTypeRaw == null || scheduleTypeRaw.isEmpty) {
      throw ScheduleTemplateCatalogException(
        'Template $id scheduleType is required',
      );
    }

    final intervalValue = raw['intervalValue'];
    if (intervalValue is! int || intervalValue <= 0) {
      throw ScheduleTemplateCatalogException(
        'Template $id intervalValue must be a positive integer',
      );
    }

    final intervalUnit = raw['intervalUnit']?.toString();
    if (intervalUnit == null || intervalUnit.isEmpty) {
      throw ScheduleTemplateCatalogException(
        'Template $id intervalUnit is required',
      );
    }

    return ScheduleTemplate(
      id: id,
      labelEn: labelEn,
      labelFa: labelFa,
      scheduleType: ScheduleTypeX.fromStorage(scheduleTypeRaw),
      intervalValue: intervalValue,
      intervalUnit: intervalUnit,
    );
  }

  /// Visible for tests — clears the in-memory cache.
  static void resetCacheForTesting() {
    _cache = null;
  }
}
