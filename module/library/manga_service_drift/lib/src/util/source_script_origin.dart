/// Where a row of `source_script_tables` came from (issue #115).
///
/// Stored as its [Enum.name] via drift's `textEnum`; never rename or remove a
/// value without a migration, because an unknown stored name throws while
/// rows are mapped.
///
/// Usage: read `SourceScriptDrift.origin` to decide whether a script is a
/// user-edited copy of a shipped (bundled) script or a user-created one.
library;

enum SourceScriptOrigin {
  /// A bundled script the user has edited; `baseVersion` records the shipped
  /// version it was forked from.
  shippedEdited,

  /// A script created entirely by the user.
  custom,
}
