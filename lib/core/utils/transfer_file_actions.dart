import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:nasyad/domain/entities/export_format.dart';

enum TransferShareOutcome { shared, copiedToClipboard }

class TransferFileActions {
  const TransferFileActions();

  Future<TransferShareOutcome> share({
    required String content,
    required String fileName,
    required ExportFormat format,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content, encoding: utf8);
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: format.mimeType, name: fileName)],
          subject: fileName,
        ),
      );
      return TransferShareOutcome.shared;
    } on UnimplementedError {
      await Clipboard.setData(ClipboardData(text: content));
      return TransferShareOutcome.copiedToClipboard;
    }
  }

  Future<String?> save({
    required String content,
    required String fileName,
    required ExportFormat format,
  }) async {
    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        XTypeGroup(
          label: format.name,
          extensions: [format.fileExtension],
          mimeTypes: [format.mimeType],
        ),
      ],
    );
    if (location == null) return null;
    await File(location.path).writeAsString(content, encoding: utf8);
    return location.path;
  }

  Future<({String content, String name})?> pickImportFile() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Nasyad export',
          extensions: ['json', 'csv', 'txt'],
          mimeTypes: ['application/json', 'text/csv', 'text/plain'],
        ),
      ],
    );
    if (file == null) return null;
    final content = await file.readAsString();
    return (content: content, name: file.name);
  }
}
