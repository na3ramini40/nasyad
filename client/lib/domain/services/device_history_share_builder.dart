import 'package:nasyad/domain/entities/device_history_share.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_log_kind.dart';
import 'package:nasyad/domain/entities/device_summary.dart';

/// Builds a shareable maintenance-history tree from a device subtree.
///
/// Only [DeviceLogKind.maintenanceDone] logs are included, oldest first.
/// Nodes with no maintenance in their subtree are pruned.
DeviceHistoryShareDocument? buildDeviceHistoryShare({
  required DeviceSummary summary,
  required Map<String, List<DeviceLog>> logsByDeviceId,
  required String title,
}) {
  final root = _buildNode(summary, logsByDeviceId);
  if (root == null || !root.hasMaintenance) return null;
  return DeviceHistoryShareDocument(root: root, title: title);
}

DeviceHistoryShareNode? _buildNode(
  DeviceSummary summary,
  Map<String, List<DeviceLog>> logsByDeviceId,
) {
  final rawLogs = logsByDeviceId[summary.device.id] ?? const <DeviceLog>[];
  final lines =
      rawLogs
          .where((log) => log.kind == DeviceLogKind.maintenanceDone)
          .map(
            (log) => DeviceHistoryShareLine(
              date: log.date,
              notes: _trimOrNull(log.notes),
              vendor: _trimOrNull(log.vendor),
              cost: log.cost,
              costCurrency: log.costCurrency,
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  final children = <DeviceHistoryShareNode>[];
  for (final child in summary.children) {
    final node = _buildNode(child, logsByDeviceId);
    if (node != null) children.add(node);
  }

  if (lines.isEmpty && children.isEmpty) return null;

  return DeviceHistoryShareNode(
    name: summary.device.name,
    locationLabel: _trimOrNull(summary.device.locationLabel),
    description: _trimOrNull(summary.device.description),
    lines: lines,
    children: children,
  );
}

String? _trimOrNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
