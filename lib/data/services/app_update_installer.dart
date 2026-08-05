import 'dart:io';

import 'package:nasyad/data/services/app_update_installer_android.dart';
import 'package:nasyad/data/services/app_update_installer_linux.dart';
import 'package:nasyad/data/services/app_update_installer_stub.dart';
import 'package:nasyad/data/services/app_update_installer_windows.dart';

export 'app_update_installer_stub.dart';

AppUpdateInstaller createAppUpdateInstaller() {
  if (Platform.isAndroid) return AndroidAppUpdateInstaller();
  if (Platform.isLinux) return LinuxAppUpdateInstaller();
  if (Platform.isWindows) return WindowsAppUpdateInstaller();
  return UnsupportedAppUpdateInstaller();
}
