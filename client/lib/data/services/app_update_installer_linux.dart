import 'dart:io';

import 'package:nasyad/data/services/app_update_installer_stub.dart';
import 'package:nasyad/domain/entities/app_release.dart';

class LinuxAppUpdateInstaller implements AppUpdateInstaller {
  @override
  Future<void> install(AppRelease release, String localPath) async {
    final executable = Platform.resolvedExecutable;
    final installDir = File(executable).parent.path;
    final execName = File(executable).uri.pathSegments.last;

    final workDir = Directory('$installDir/.nasyad_update');
    if (await workDir.exists()) {
      await workDir.delete(recursive: true);
    }
    await workDir.create(recursive: true);

    final stagingDir = Directory('${workDir.path}/staging');
    await stagingDir.create(recursive: true);

    final extract = await Process.run('tar', [
      'xzf',
      localPath,
      '-C',
      stagingDir.path,
    ]);
    if (extract.exitCode != 0) {
      throw StateError('Extract failed: ${extract.stderr}');
    }

    final updaterPath = '${workDir.path}/nasyad_updater.sh';
    final updater = File(updaterPath);
    await updater.writeAsString(r'''#!/bin/bash
set -e
INSTALL_DIR="$1"
STAGING_DIR="$2"
EXEC_NAME="$3"
PID="$4"

while kill -0 "$PID" 2>/dev/null; do
  sleep 1
done

cp -a "$STAGING_DIR/." "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$EXEC_NAME"
exec "$INSTALL_DIR/$EXEC_NAME" >/dev/null 2>&1 &
''');

    await Process.run('chmod', ['+x', updaterPath]);
    await Process.start('/bin/bash', [
      updaterPath,
      installDir,
      stagingDir.path,
      execName,
      '$pid',
    ], mode: ProcessStartMode.detached);

    exit(0);
  }
}
