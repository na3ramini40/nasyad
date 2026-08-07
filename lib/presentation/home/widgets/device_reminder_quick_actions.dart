import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/ui/ui.dart';

Future<void> showDeviceReminderQuickActions({
  required BuildContext context,
  required String deviceId,
  required String deviceName,
}) {
  final l10n = AppLocalizations.of(context);

  return showAppBottomSheet<void>(
    context: context,
    title: deviceName,
    builder: (sheetContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: Text(l10n.markMaintained),
            onTap: () {
              sheetContext.pop();
              context.push('/device/$deviceId/log');
            },
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: Text(l10n.updateUsage),
            onTap: () {
              sheetContext.pop();
              context.push('/device/$deviceId/log?kind=usage');
            },
          ),
        ],
      );
    },
  );
}
