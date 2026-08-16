import 'package:flutter/services.dart';

const _channelName = 'amini.apps.nasyad/app_update';

/// Reads [Build.SUPPORTED_ABIS] via the app-update MethodChannel.
Future<List<String>> readAndroidSupportedAbis({MethodChannel? channel}) async {
  final resolved = channel ?? const MethodChannel(_channelName);
  final raw = await resolved.invokeMethod<List<dynamic>>('getSupportedAbis');
  if (raw == null) return const [];
  return [for (final item in raw) item.toString()];
}
