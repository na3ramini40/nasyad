/// Canonical deep link URI format for Nasyad.
///
/// **Scheme:** `nasyad`
///
/// **Path:** mirrors [go_router] locations (leading slash in the URI path).
///
/// ```text
/// nasyad:///<location>[?query]
/// ```
///
/// Examples:
/// - `nasyad:///` — home
/// - `nasyad:///devices`
/// - `nasyad:///preferences/transfer`
/// - `nasyad:///birthdays/new`
/// - `nasyad:///birthdays/{id}/edit`
/// - `nasyad:///device/new?parentId={id}`
/// - `nasyad:///device/{id}`
/// - `nasyad:///device/{id}/edit`
/// - `nasyad:///device/{id}/log?kind=usage|maintenance`
///
/// A host-only form is also accepted for convenience (`nasyad://devices` →
/// `/devices`). Splash is not exposed for external deep links.
abstract final class DeepLinkConstants {
  static const scheme = 'nasyad';
}
