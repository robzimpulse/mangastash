/// Error raised when a JavaScript source script fails while it runs.
///
/// Purpose: carries everything the editor UI needs to point at the problem -
/// the called script [function], the [message], the 1-based [line]/[column]
/// inside the script (null when the stack had no script frame), the raw [stack]
/// text the page posted (null for harness-raised errors and timeouts), the
/// page [url] it ran against, the id of the [source], a snapshot of the page
/// [html] and whether the call [timedOut].
/// Usage: thrown by the source script runner; catch it and read the fields, or
/// print it: "SourceScriptException: {source} {function} failed at line {line}:
/// {message}" (missing parts are omitted). Use [copyWith] to attach the
/// [source] id and [html] snapshot once they are known.
library;

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
    );
  }

  @override
  String toString() {
    final prefix = source == null ? '' : '$source ';
    final location = line == null ? '' : ' at line $line';
    return 'SourceScriptException: $prefix$function failed$location: $message';
  }
}
