import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum DeviceHistoryShareOutcome { shared, copiedToClipboard }

class DeviceHistoryShareActions {
  const DeviceHistoryShareActions();

  Future<DeviceHistoryShareOutcome> sharePdf({
    required Uint8List bytes,
    required String fileName,
    required String subject,
    required String plainTextFallback,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(file.path, mimeType: 'application/pdf', name: fileName),
          ],
          subject: subject,
        ),
      );
      return DeviceHistoryShareOutcome.shared;
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: plainTextFallback));
      return DeviceHistoryShareOutcome.copiedToClipboard;
    }
  }

  Future<void> copyPlainText(String text) {
    return Clipboard.setData(ClipboardData(text: text));
  }
}
