// FixSourceTarget / fixSourceTargetOf: decide whether an error can be answered
// with the "Fix source" action (issue #115) and what the source editor should
// prefill (the failing source, script function and page URL).
//
// Only errors raised by a source *script* qualify: a SourceScriptException
// carrying the source name, or a FailedParsingHtmlException that names both
// its source and the parser (script function: search | manga | chapters |
// images). MangaDex is a native built-in with no script and never raises
// these, so it never gets the action; the feature layer additionally resolves
// the name to a script id and does nothing when the source has none.
//
// Usage:
//   final target = fixSourceTargetOf(error);
//   if (target != null) onTapFixSource?.call(target);
import 'package:core_network/core_network.dart';

class FixSourceTarget {
  const FixSourceTarget({
    required this.sourceName,
    required this.function,
    this.url,
  });

  /// Display name of the failing source (resolved to a script id by the
  /// feature layer).
  final String sourceName;

  /// Script function that failed, e.g. `search` or `chapters`.
  final String function;

  /// Page the function ran against, when known.
  final String? url;

  @override
  bool operator ==(Object other) {
    return other is FixSourceTarget &&
        other.sourceName == sourceName &&
        other.function == function &&
        other.url == url;
  }

  @override
  int get hashCode => Object.hash(sourceName, function, url);

  @override
  String toString() => 'FixSourceTarget($sourceName, $function, $url)';
}

/// The editor target for [error], or null when [error] is not a script
/// failure that names its source.
FixSourceTarget? fixSourceTargetOf(Object? error) {
  if (error is SourceScriptException) {
    final source = error.source;
    if (source == null) return null;
    return FixSourceTarget(
      sourceName: source,
      function: error.function,
      url: error.url,
    );
  }
  if (error is FailedParsingHtmlException) {
    final source = error.source;
    final parser = error.parser;
    if (source == null || parser == null) return null;
    return FixSourceTarget(
      sourceName: source,
      function: parser,
      url: error.url,
    );
  }
  return null;
}
