import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:nasyad/domain/entities/device_history_share.dart';

Future<Uint8List> buildDeviceHistoryPdf(
  DeviceHistoryShareDocument document, {
  required pw.Font font,
  required String Function(DateTime date) formatDate,
  required String Function(double cost, String? currencyLabel) formatCost,
}) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: pw.ThemeData.withFont(base: font),
      build: (context) => [
        pw.Text(
          document.title,
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 16),
        ..._nodeWidgets(
          document.root,
          depth: 0,
          font: font,
          formatDate: formatDate,
          formatCost: formatCost,
        ),
      ],
    ),
  );
  return pdf.save();
}

List<pw.Widget> _nodeWidgets(
  DeviceHistoryShareNode node, {
  required int depth,
  required pw.Font font,
  required String Function(DateTime date) formatDate,
  required String Function(double cost, String? currencyLabel) formatCost,
}) {
  final indent = depth * 16.0;
  final widgets = <pw.Widget>[
    pw.Padding(
      padding: pw.EdgeInsets.only(left: indent, top: depth == 0 ? 0 : 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            node.name,
            style: pw.TextStyle(
              font: font,
              fontSize: depth == 0 ? 14 : 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (node.locationLabel != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                node.locationLabel!,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          if (node.description != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                node.description!,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 10,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          for (final line in node.lines)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4, left: 8),
              child: pw.Text(
                _lineText(line, formatDate: formatDate, formatCost: formatCost),
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
            ),
        ],
      ),
    ),
  ];

  for (final child in node.children) {
    widgets.addAll(
      _nodeWidgets(
        child,
        depth: depth + 1,
        font: font,
        formatDate: formatDate,
        formatCost: formatCost,
      ),
    );
  }
  return widgets;
}

String _lineText(
  DeviceHistoryShareLine line, {
  required String Function(DateTime date) formatDate,
  required String Function(double cost, String? currencyLabel) formatCost,
}) {
  final parts = <String>[formatDate(line.date)];
  final notes = line.notes;
  if (notes != null) parts.add(notes);
  final vendor = line.vendor;
  if (vendor != null) parts.add(vendor);
  final cost = line.cost;
  if (cost != null) parts.add(formatCost(cost, line.costCurrency));
  return '- ${parts.join(' | ')}';
}
