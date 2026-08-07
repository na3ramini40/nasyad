/// GitHub repository used for release checks and update downloads.
///
/// Set at build/run via `--dart-define` (from `.env/app.env` through `./tool/dev.sh`):
/// `GITHUB_OWNER`, `GITHUB_REPO`. Empty values disable the official update channel
/// so forks do not pull the owner's releases.
abstract final class GitHubConfig {
  static const String owner = String.fromEnvironment('GITHUB_OWNER');
  static const String repo = String.fromEnvironment('GITHUB_REPO');

  static bool get isConfigured => owner.isNotEmpty && repo.isNotEmpty;

  static Uri latestReleaseUri() {
    if (!isConfigured) {
      throw StateError(
        'GitHub update channel is not configured '
        '(set GITHUB_OWNER and GITHUB_REPO in .env/app.env).',
      );
    }
    return Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest');
  }
}
