/// Thrown when an injected script reports a JS error over the
/// `scriptError` bridge handler. Surfaces what used to fail silently and
/// left the parser reading an unprepared DOM.
class ScriptEvaluationException implements Exception {
  final int scriptIndex;
  final String error;
  final String url;

  ScriptEvaluationException({
    required this.scriptIndex,
    required this.error,
    required this.url,
  });

  @override
  String toString() =>
      '$runtimeType : script #$scriptIndex threw "$error" on $url';
}
