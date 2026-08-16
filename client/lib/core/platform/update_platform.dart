import 'dart:io' show Platform;

import 'package:nasyad/core/version/semver.dart';

/// Platforms that CI ships release assets for.
enum UpdatePlatform { android, linux, windows, unsupported }

/// ABIs we publish as split release APKs, preferred order for matching.
const List<String> kShippedAndroidAbis = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];

UpdatePlatform currentUpdatePlatform() {
  if (Platform.isAndroid) return UpdatePlatform.android;
  if (Platform.isLinux) return UpdatePlatform.linux;
  if (Platform.isWindows) return UpdatePlatform.windows;
  return UpdatePlatform.unsupported;
}

/// Expected GitHub release asset file name for [platform] and [versionName].
///
/// For [UpdatePlatform.android], [androidAbi] is required (e.g. `arm64-v8a`).
String releaseAssetName(
  UpdatePlatform platform,
  String versionName, {
  String? androidAbi,
}) {
  switch (platform) {
    case UpdatePlatform.android:
      if (androidAbi == null || androidAbi.isEmpty) {
        throw ArgumentError.value(
          androidAbi,
          'androidAbi',
          'required for Android release assets',
        );
      }
      return 'nasyad-v$versionName-$androidAbi.apk';
    case UpdatePlatform.linux:
      return 'nasyad-v$versionName-linux-x64.tar.gz';
    case UpdatePlatform.windows:
      return 'nasyad-v$versionName-windows-x64.zip';
    case UpdatePlatform.unsupported:
      return '';
  }
}

/// Shipped ABIs that [deviceAbis] can run, in publish preference order.
List<String> androidAbiCandidates(List<String> deviceAbis) {
  final deviceSet = deviceAbis.toSet();
  return [
    for (final abi in kShippedAndroidAbis)
      if (deviceSet.contains(abi)) abi,
  ];
}

/// Picks an Android APK asset present in [availableNames], preferring
/// [deviceAbis] against [kShippedAndroidAbis] order.
String? pickAndroidReleaseAssetName({
  required String versionName,
  required List<String> deviceAbis,
  required Iterable<String> availableNames,
}) {
  final names = availableNames is Set<String>
      ? availableNames
      : availableNames.toSet();
  for (final abi in androidAbiCandidates(deviceAbis)) {
    final name = releaseAssetName(
      UpdatePlatform.android,
      versionName,
      androidAbi: abi,
    );
    if (names.contains(name)) return name;
  }
  return null;
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
