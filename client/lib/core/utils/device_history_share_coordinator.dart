import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:nasyad/core/calendar/preferred_datetime_formatter.dart';
import 'package:nasyad/core/utils/device_history_share_actions.dart';
import 'package:nasyad/core/utils/log_cost_formatter.dart';
import 'package:nasyad/domain/entities/calendar_system.dart';
import 'package:nasyad/domain/entities/device_history_share.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/services/device_history_pdf_builder.dart';
import 'package:nasyad/domain/services/device_history_plain_text.dart';
import 'package:nasyad/domain/usecases/device/prepare_device_history_share_usecase.dart';

enum ShareDeviceHistoryResult { empty, shared, copiedToClipboard }

/// Orchestrates prepare → PDF share, with plain-text clipboard fallback.
class ShareDeviceHistoryCoordinator {
  ShareDeviceHistoryCoordinator({
    required PrepareDeviceHistoryShareUsecase prepare,
    DeviceHistoryShareActions actions = const DeviceHistoryShareActions(),
    Future<ByteData> Function()? loadFont,
  }) : _prepare = prepare,
       _actions = actions,
       _loadFont = loadFont ?? _defaultLoadFont;

  final PrepareDeviceHistoryShareUsecase _prepare;
  final DeviceHistoryShareActions _actions;
  final Future<ByteData> Function() _loadFont;

  Future<ShareDeviceHistoryResult> share({
    required DeviceSummary summary,
    required CalendarSystem calendar,
    required Locale locale,
    required String documentTitle,
  }) async {
    final document = await _prepare(
      summary: summary,
      documentTitle: documentTitle,
    );
    if (document == null) return ShareDeviceHistoryResult.empty;

    return shareDocument(
      document: document,
      summary: summary,
      calendar: calendar,
      locale: locale,
    );
  }

  Future<ShareDeviceHistoryResult> shareDocument({
    required DeviceHistoryShareDocument document,
    required DeviceSummary summary,
    required CalendarSystem calendar,
    required Locale locale,
  }) async {
    String formatDate(DateTime date) =>
        formatPreferredDateTime(date, calendar: calendar, locale: locale);
    String formatCost(double cost, String? currency) =>
        formatLogCost(locale, cost, currencyLabel: currency);

    final plainText = renderDeviceHistoryPlainText(
      document,
      formatDate: formatDate,
      formatCost: formatCost,
    );

    try {
      final fontData = await _loadFont();
      final font = pw.Font.ttf(fontData);
      final pdfBytes = await buildDeviceHistoryPdf(
        document,
        font: font,
        formatDate: formatDate,
        formatCost: formatCost,
      );
      if (pdfBytes.isEmpty) {
        throw StateError('empty pdf');
      }
      final safeName = _safeFileName(summary.device.name);
      final outcome = await _actions.sharePdf(
        bytes: pdfBytes,
        fileName: '${safeName}_maintenance_history.pdf',
        subject: document.title,
        plainTextFallback: plainText,
      );
      return switch (outcome) {
        DeviceHistoryShareOutcome.shared => ShareDeviceHistoryResult.shared,
        DeviceHistoryShareOutcome.copiedToClipboard =>
          ShareDeviceHistoryResult.copiedToClipboard,
      };
    } catch (_) {
      await _actions.copyPlainText(plainText);
      return ShareDeviceHistoryResult.copiedToClipboard;
    }
  }

  static Future<ByteData> _defaultLoadFont() {
    return rootBundle.load('fonts/vazir/Vazir-Regular.ttf');
  }

  static String _safeFileName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^\w\-]+'), '_');
    if (cleaned.isEmpty) return 'device';
    return cleaned.length > 40 ? cleaned.substring(0, 40) : cleaned;
  }
}
