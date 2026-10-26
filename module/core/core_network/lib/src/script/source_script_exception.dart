/// Error raised when a JavaScript source script fails while it runs.
///
/// Purpose: carries everything the editor UI needs to point at the problem -
/// the called script [function], the [message], the 1-based [line]/[column]
/// inside the script (null when the stack had no script frame), the raw [stack]
/// text the page posted (null for harness-raised errors and timeouts), the
/// page [url] it ran against, the id of the [source], a snapshot of the page
/// [html], whether the call [timedOut], and whether the page or script
/// runner never loaded ([loadFailed]: the script did not run, so the failure
/// is transient and not a script fault; the UI offers Retry, not Fix source).
/// Usage: thrown by the source script runner; catch it and read the fields, or
/// print it: "SourceScriptException: {source} {function} failed at line {line}:
/// {message}" (missing parts are omitted). Use [copyWith] to attach the
/// [source] id and [html] snapshot once they are known.
/// [isTransientLoadError] tells the UI whether an error is such a load
/// failure (offer Retry) rather than a script fault (offer Fix source).
library;

/// Whether [error] is a [SourceScriptException] whose page or script runner
/// never loaded ([SourceScriptException.loadFailed]): the script did not
/// run, so retrying can help and editing the script cannot.
bool isTransientLoadError(Object? error) {
  return error is SourceScriptException && error.loadFailed;
}

class SourceScriptException implements Exception {
  const SourceScriptException({
    required this.function,
    required this.message,
    this.line,
    this.column,
    this.stack,
    this.url,
    this.source,
    this.html,
    this.timedOut = false,
    this.loadFailed = false,
  });

  final String function;
  final String message;
  final int? line;
  final int? column;

  /// Raw stack text of the script error, as posted by the page; names the
  /// failing helper/frame inside the script. Null when the harness raised
  /// (its own errors carry no script frame) or the call timed out.
  final String? stack;
  final String? url;
  final String? source;
  final String? html;
  final bool timedOut;

  /// The page (or the blank script runner) failed to load in time, or its
  /// renderer died while loading, so the script never ran. Such failures are
  /// transient: retrying can succeed, and editing the script cannot help.
  final bool loadFailed;

  SourceScriptException copyWith({String? source, String? html}) {
    return SourceScriptException(
      function: function,
      message: message,
      line: line,
      column: column,
      stack: stack,
      url: url,
      source: source ?? this.source,
      html: html ?? this.html,
      timedOut: timedOut,
      loadFailed: loadFailed,
    );
  }

  @override
  String toString() {
    final prefix = source == null ? '' : '$source ';
    final location = line == null ? '' : ' at line $line';
    return 'SourceScriptException: $prefix$function failed$location: $message';
  }
}
