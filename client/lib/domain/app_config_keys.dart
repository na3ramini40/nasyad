/// Known remote feature-flag keys (`docs/domain/app-config.md`).
///
/// Product screens must not gate on [exampleRemoteFlag] until a real feature
/// opts in; it exists only as plumbing proof.
abstract final class AppConfigKeys {
  static const exampleRemoteFlag = 'example_remote_flag';
}
