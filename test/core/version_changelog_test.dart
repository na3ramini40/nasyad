import 'package:flutter_test/flutter_test.dart';
import 'package:nasyad/core/version/app_changelog.dart';
import 'package:nasyad/core/version/app_version.dart';
import 'package:nasyad/core/version/semver.dart';

void main() {
  group('SemVer', () {
    test('parses name and build', () {
      final version = SemVer.parse('1.2.3+9');
      expect(version.major, 1);
      expect(version.minor, 2);
      expect(version.patch, 3);
      expect(version.build, 9);
      expect(version.name, '1.2.3');
      expect(version.full, '1.2.3+9');
    });

    test('defaults build to 1 when missing', () {
      expect(SemVer.parse('2.0.0').build, 1);
    });

    test('bumps major minor patch and increments build', () {
      final base = SemVer.parse('1.2.3+4');
      expect(base.bump(BumpKind.patch).full, '1.2.4+5');
      expect(base.bump(BumpKind.minor).full, '1.3.0+5');
      expect(base.bump(BumpKind.major).full, '2.0.0+5');
    });

    test('compareName ignores build', () {
      expect(SemVer.parse('1.2.3+1').compareName(SemVer.parse('1.2.3+99')), 0);
      expect(
        SemVer.parse('1.2.4').compareName(SemVer.parse('1.2.3')),
        greaterThan(0),
      );
      expect(
        SemVer.parse('1.1.0').compareName(SemVer.parse('1.2.0')),
        lessThan(0),
      );
    });

    test('parseBumpKind', () {
      expect(parseBumpKind('patch'), BumpKind.patch);
      expect(parseBumpKind('MINOR'), BumpKind.minor);
      expect(parseBumpKind('nope'), isNull);
    });
  });

  group('decideWhatsNew', () {
    test('first install skips dialog', () {
      expect(
        decideWhatsNew(lastSeen: null, current: '1.0.0'),
        WhatsNewDecision.skipFirstInstall,
      );
      expect(
        decideWhatsNew(lastSeen: '', current: '1.0.0'),
        WhatsNewDecision.skipFirstInstall,
      );
    });

    test('same version is already seen', () {
      expect(
        decideWhatsNew(lastSeen: '1.0.0', current: '1.0.0'),
        WhatsNewDecision.alreadySeen,
      );
    });

    test('different version shows update', () {
      expect(
        decideWhatsNew(lastSeen: '1.0.0', current: '1.1.0'),
        WhatsNewDecision.showUpdate,
      );
    });
  });

  group('changelogEntriesSince', () {
    const newer = ChangelogEntry(version: '1.1.0', en: ['A'], fa: ['آ']);
    const older = ChangelogEntry(version: '1.0.0', en: ['B'], fa: ['ب']);

    test('returns entries newer than last seen', () {
      final result = changelogEntriesSince([newer, older], '1.0.0');
      expect(result.map((e) => e.version), ['1.1.0']);
    });

    test('falls back to latest when nothing newer', () {
      final result = changelogEntriesSince([older], '1.0.0');
      expect(result.single.version, '1.0.0');
    });

    test('seeded changelog latest matches AppVersion', () {
      expect(AppChangelog.latest?.version, AppVersion.name);
      expect(AppChangelog.entriesSince('1.3.0').first.version, '1.4.0');
      expect(AppChangelog.entries.map((e) => e.version), contains('1.0.0'));
    });

    test('every entry has end-user notes for all l10n languages', () {
      expect(changelogLanguageCodes, ['en', 'fa']);
      for (final entry in AppChangelog.entries) {
        expect(
          entry.hasNotesForAllLanguages,
          isTrue,
          reason: '${entry.version} missing notes for a language',
        );
        for (final code in changelogLanguageCodes) {
          expect(entry.notesFor(code), isNotEmpty);
        }
      }
    });
  });
}
