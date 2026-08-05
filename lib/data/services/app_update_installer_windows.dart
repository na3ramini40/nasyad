import 'dart:io';

import 'package:nasyad/data/services/app_update_installer_stub.dart';
import 'package:nasyad/domain/entities/app_release.dart';

class WindowsAppUpdateInstaller implements AppUpdateInstaller {
  @override
  Future<void> install(AppRelease release, String localPath) async {
    final executable = Platform.resolvedExecutable;
    final installDir = File(executable).parent.path;
    final execName = File(executable).uri.pathSegments.last;

    final workDir = Directory('$installDir\\nasyad_update');
    if (await workDir.exists()) {
      await workDir.delete(recursive: true);
    }
    await workDir.create(recursive: true);

    final stagingDir = Directory('${workDir.path}\\staging');
    await stagingDir.create(recursive: true);

    final extract = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      'Expand-Archive -Path "${localPath.replaceAll('/', '\\')}" -DestinationPath "${stagingDir.path}" -Force',
    ]);
    if (extract.exitCode != 0) {
      throw StateError('Extract failed: ${extract.stderr}');
    }

    final updaterPath = '${workDir.path}\\nasyad_updater.ps1';
    final updater = File(updaterPath);
    await updater.writeAsString('''
param(
  [string]\$InstallDir,
  [string]\$StagingDir,
  [string]\$ExecName,
  [int]\$Pid
)

while (Get-Process -Id \$Pid -ErrorAction SilentlyContinue) {
  Start-Sleep -Seconds 1
}

Copy-Item -Path "\$StagingDir\\*" -Destination \$InstallDir -Recurse -Force
Start-Process -FilePath (Join-Path \$InstallDir \$ExecName)
''');

    await Process.start('powershell', [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      updaterPath,
      installDir,
      stagingDir.path,
      execName,
      '$pid',
    ], mode: ProcessStartMode.detached);

    exit(0);
  }
}
