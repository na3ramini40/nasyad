import 'package:nasyad/domain/entities/device_history_share.dart';
import 'package:nasyad/domain/entities/device_log.dart';
import 'package:nasyad/domain/entities/device_summary.dart';
import 'package:nasyad/domain/repositories/device_log_repository.dart';
import 'package:nasyad/domain/services/device_history_share_builder.dart';

/// Collects subtree logs and builds a maintenance-history share document.
///
/// Returns `null` when the subtree has no [DeviceLogKind.maintenanceDone] logs.
class PrepareDeviceHistoryShareUsecase {
  PrepareDeviceHistoryShareUsecase(this._logs);

  final DeviceLogRepository _logs;

  Future<DeviceHistoryShareDocument?> call({
    required DeviceSummary summary,
    required String documentTitle,
  }) async {
    final logsByDeviceId = <String, List<DeviceLog>>{};
    await _collectLogs(summary, logsByDeviceId);
    return buildDeviceHistoryShare(
      summary: summary,
      logsByDeviceId: logsByDeviceId,
      title: documentTitle,
    );
  }

  Future<void> _collectLogs(
    DeviceSummary summary,
    Map<String, List<DeviceLog>> out,
  ) async {
    out[summary.device.id] = await _logs.getLogsForDevice(summary.device.id);
    for (final child in summary.children) {
      await _collectLogs(child, out);
    }
  }
}
