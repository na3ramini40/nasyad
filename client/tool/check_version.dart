import 'dart:io';

import 'package:nasyad/core/version/app_changelog.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/core/version/semver.dart';

/// Ensures pubspec, AppVersion, AppChangelog, and server OpenAPI version stay aligned.
///
/// Usage:
///   dart run tool/check_version.dart
///   dart run tool/check_version.dart --tag v1.3.0
void main(List<String> args) {
  final packageRoot = _findPackageRoot();
  final repoRoot = _findRepoRoot(packageRoot);
  final pubspec = File('${packageRoot.path}/pubspec.yaml').readAsStringSync();
  final match = RegExp(
    r'^version:\s*(\d+\.\d+\.\d+(?:\+\d+)?)\s*$',
    multiLine: true,
  ).firstMatch(pubspec);
  if (match == null) {
    stderr.writeln('Could not find version: line in pubspec.yaml');
    exitCode = 1;
    return;
  }

  final pubspecVersion = SemVer.parse(match.group(1)!);
  final errors = <String>[];

  if (pubspecVersion.full != AppVersion.full) {
    errors.add(
      'pubspec.yaml (${pubspecVersion.full}) != AppVersion.full '
      '(${AppVersion.full})',
    );
  }

  if (pubspecVersion.name != AppVersion.name) {
    errors.add(
      'pubspec name (${pubspecVersion.name}) != AppVersion.name '
      '(${AppVersion.name})',
    );
  }

  final latest = AppChangelog.latest;
  if (latest == null) {
    errors.add('AppChangelog.entries is empty');
  } else if (latest.version != AppVersion.name) {
    errors.add(
      'AppChangelog.latest (${latest.version}) != AppVersion.name '
      '(${AppVersion.name})',
    );
  } else if (!latest.hasNotesForAllLanguages) {
    errors.add(
      'Changelog for ${latest.version} must have end-user notes for every '
      'lib/l10n language (${changelogLanguageCodes.join(', ')})',
    );
  }

  for (final entry in AppChangelog.entries) {
    if (!entry.hasNotesForAllLanguages) {
      errors.add(
        'Changelog ${entry.version} is missing notes for one or more '
        'languages (${changelogLanguageCodes.join(', ')})',
      );
    }
  }

  final serverVersion = _readServerOpenApiVersion(repoRoot);
  if (serverVersion == null) {
    errors.add(
      'Could not find SPECTACULAR_SETTINGS VERSION in '
      'server/config/settings.py',
    );
  } else if (serverVersion != AppVersion.name) {
    errors.add(
      'server SPECTACULAR VERSION ($serverVersion) != AppVersion.name '
      '(${AppVersion.name})',
    );
  }

  final releaseNotes = File(
    '${repoRoot.path}/docs/domain/releases/v${AppVersion.name}.md',
  );
  if (!releaseNotes.existsSync()) {
    errors.add(
      'Missing GitHub release notes at '
      'docs/domain/releases/v${AppVersion.name}.md',
    );
  }

  String? tagArg;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--tag' && i + 1 < args.length) {
      tagArg = args[i + 1];
    }
  }
  if (tagArg != null && tagArg.isNotEmpty) {
    final tagName = tagArg.startsWith('v') ? tagArg.substring(1) : tagArg;
    try {
      final tagVersion = SemVer.parse(tagName);
      if (tagVersion.name != AppVersion.name) {
        errors.add(
          'Git tag ($tagArg) name (${tagVersion.name}) != AppVersion.name '
          '(${AppVersion.name})',
        );
      }
    } on FormatException {
      errors.add('Git tag ($tagArg) is not a valid semver tag like v1.1.0');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Version check failed:');
    for (final error in errors) {
      stderr.writeln('  - $error');
    }
    stderr.writeln(
      'Fix with: dart run tool/bump_version.dart <major|minor|patch> '
      '(keeps server OpenAPI version in sync), update '
      'lib/core/version/app_changelog.dart, and '
      'docs/domain/releases/vX.Y.Z.md',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Version OK: ${AppVersion.full} '
    '(changelog ${AppChangelog.latest!.version}, '
    'server $serverVersion, '
    'notes docs/domain/releases/v${AppVersion.name}.md)',
  );
}

Directory _findPackageRoot() {
  var dir = Directory.current;
  while (true) {
    if (File('${dir.path}/pubspec.yaml').existsSync()) return dir;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'Could not find pubspec.yaml from ${Directory.current.path}',
      );
    }
    dir = parent;
  }
}

Directory _findRepoRoot(Directory packageRoot) {
  if (packageRoot.path.endsWith('${Platform.pathSeparator}client') ||
      packageRoot.path.endsWith('/client')) {
    return packageRoot.parent;
  }
  // Already at monorepo root (pubspec only under client/ in this repo).
  if (Directory('${packageRoot.path}/server').existsSync() &&
      Directory('${packageRoot.path}/client').existsSync()) {
    return packageRoot;
  }
  final parent = packageRoot.parent;
  if (Directory('${parent.path}/server').existsSync()) return parent;
  return packageRoot;
}

String? _readServerOpenApiVersion(Directory repoRoot) {
  final settings = File('${repoRoot.path}/server/config/settings.py');
  if (!settings.existsSync()) return null;
  final text = settings.readAsStringSync();
  final match = RegExp(r'"VERSION"\s*:\s*"(\d+\.\d+\.\d+)"').firstMatch(text);
  return match?.group(1);
}
