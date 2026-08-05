/// GitHub repository used for release checks and update downloads.
abstract final class GitHubConfig {
  static const String owner = 'na3ramini40';
  static const String repo = 'nasyad';

  static Uri latestReleaseUri() =>
      Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest');
}
