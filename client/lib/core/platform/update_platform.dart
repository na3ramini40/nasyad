import 'dart:io' show Platform;

import 'package:nasyad/core/version/semver.dart';

/// Platforms that CI ships release assets for.
enum UpdatePlatform { android, linux, windows, unsupported }

UpdatePlatform currentUpdatePlatform() {
  if (Platform.isAndroid) return UpdatePlatform.android;
  if (Platform.isLinux) return UpdatePlatform.linux;
  if (Platform.isWindows) return UpdatePlatform.windows;
  return UpdatePlatform.unsupported;
}

/// Expected GitHub release asset file name for [platform] and [versionName].
String releaseAssetName(UpdatePlatform platform, String versionName) {
  return switch (platform) {
    UpdatePlatform.android => 'nasyad-v$versionName.apk',
    UpdatePlatform.linux => 'nasyad-v$versionName-linux-x64.tar.gz',
    UpdatePlatform.windows => 'nasyad-v$versionName-windows-x64.zip',
    UpdatePlatform.unsupported => '',
  };
}

/// Parses `vX.Y.Z` tag names from GitHub releases.
String? parseReleaseTagName(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.startsWith('v')) return null;
  try {
    return SemVer.parse(trimmed.substring(1)).name;
  } on FormatException {
    return null;
  }
}
