import 'package:equatable/equatable.dart';
import 'package:nasyad/core/version/semver.dart';

/// A newer app version published on GitHub Releases with a platform asset.
class AppRelease extends Equatable {
  const AppRelease({
    required this.version,
    required this.tagName,
    required this.assetName,
    required this.downloadUrl,
    required this.sizeBytes,
    this.releaseNotes,
  });

  final SemVer version;
  final String tagName;
  final String assetName;
  final String downloadUrl;
  final int sizeBytes;
  final String? releaseNotes;

  @override
  List<Object?> get props => [
    version,
    tagName,
    assetName,
    downloadUrl,
    sizeBytes,
    releaseNotes,
  ];
}
