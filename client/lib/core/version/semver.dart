class SemVer {
  const SemVer(this.major, this.minor, this.patch, [this.build = 1]);

  final int major;
  final int minor;
  final int patch;
  final int build;

  String get name => '$major.$minor.$patch';

  String get full => '$name+$build';

  static SemVer parse(String raw) {
    final match = RegExp(
      r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$',
    ).firstMatch(raw.trim());
    if (match == null) {
      throw FormatException('Invalid semver: $raw');
    }
    return SemVer(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4) ?? '1'),
    );
  }

  SemVer bump(BumpKind kind) {
    return switch (kind) {
      BumpKind.major => SemVer(major + 1, 0, 0, build + 1),
      BumpKind.minor => SemVer(major, minor + 1, 0, build + 1),
      BumpKind.patch => SemVer(major, minor, patch + 1, build + 1),
    };
  }

  /// Compares name parts only (ignores build). Positive if this > other.
  int compareName(SemVer other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }
}

enum BumpKind { major, minor, patch }

BumpKind? parseBumpKind(String raw) {
  return switch (raw.trim().toLowerCase()) {
    'major' => BumpKind.major,
    'minor' => BumpKind.minor,
    'patch' => BumpKind.patch,
    _ => null,
  };
}

enum WhatsNewDecision { skipFirstInstall, showUpdate, alreadySeen }

WhatsNewDecision decideWhatsNew({
  required String? lastSeen,
  required String current,
}) {
  if (lastSeen == null || lastSeen.isEmpty) {
    return WhatsNewDecision.skipFirstInstall;
  }
  if (lastSeen == current) {
    return WhatsNewDecision.alreadySeen;
  }
  return WhatsNewDecision.showUpdate;
}
