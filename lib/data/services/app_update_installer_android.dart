import 'package:flutter/services.dart';
import 'package:nasyad/data/services/app_update_installer_stub.dart';
import 'package:nasyad/domain/entities/app_release.dart';

class AndroidAppUpdateInstaller implements AppUpdateInstaller {
  AndroidAppUpdateInstaller({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('amini.apps.nasyad/app_update');

  final MethodChannel _channel;

  @override
  Future<void> install(AppRelease release, String localPath) async {
    await _channel.invokeMethod<void>('installApk', {'path': localPath});
  }
}
