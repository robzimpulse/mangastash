/// Builds the JavaScript that runs one function of a MangaStash JS source
/// inside the headless webview, and parses error locations out of JS stacks.
///
/// Purpose: [buildSourceHarness] returns a self-contained script that
///   1. defines `createSourceCtx` (the shared helpers from `source_ctx.js`),
///   2. evaluates the user script by indirect eval of its JSON-encoded text with
///      `\n;source;\n//# sourceURL=mangastash-source.js` appended (identical to
///      the Node test loader), so the `const source = {...}` object is the
///      completion value and stack frames are named `mangastash-source.js`,
///   3. calls `source[function](document, ctx)` for page functions or
///      `source[function](...args, ctx)` otherwise (a missing function rejects
///      with `Error('source.<function> is not a function')`),
///   4. posts the outcome back through the inappwebview bridge:
///      `sourceResult {callId, value: <JSON string>}` or
///      `sourceError {callId, message, stack}`.
/// [parseScriptLocation] extracts `line:column` of the first script frame from
/// a WebKit (`fn@mangastash-source.js:12:9`) or Chromium
/// (`at fn (mangastash-source.js:7:15)`) stack.
/// Usage: the runner evaluates `buildSourceHarness(...)` in the page, awaits the
/// handler call, and on `sourceError` feeds `stack` to [parseScriptLocation].
/// Generated JS sticks to ES2017 plus spread (iOS 13 WebKit).
library;

import 'dart:convert';

/// JSON literal that is also safe as a JS string literal (U+2028/2029 escaped).
String _literal(Object? value) {
  return jsonEncode(
    value,
  ).replaceAll(' ', r' ').replaceAll(' ', r' ');
}

String buildSourceHarness({
  required String ctxJs,
  required String code,
  required String function,
  required String argsJson,
  required String callId,
  required String baseUrl,
  String? searchTerm,
  required bool pageFunction,
}) {
  final call = pageFunction
      ? 'source[fn](document, ctx)'
      : 'source[fn](...args, ctx)';
  // argsJson is a JSON document, therefore a valid JS expression; it is parsed
  // from a string literal anyway so malformed input becomes a sourceError
  // instead of a syntax error that would swallow the whole harness.
  return '''
(function () {
  $ctxJs
  var callId = ${_literal(callId)};
  var fn = ${_literal(function)};
  var baseUrl = ${_literal(baseUrl)};
  var searchTerm = ${_literal(searchTerm)};
  var argsJson = ${_literal(argsJson)};
  var code = ${_literal(code)};
  function post(name, payload) {
    window.flutter_inappwebview.callHandler(name, payload);
  }
  Promise.resolve().then(function () {
    var args = JSON.parse(argsJson);
    var ctx = createSourceCtx({
      doc: document,
      baseUrl: baseUrl,
      searchTerm: searchTerm === null ? undefined : searchTerm,
    });
    var source = (0, eval)(code + '\\n;source;\\n//# sourceURL=mangastash-source.js');
    if (source === null || source === undefined || typeof source[fn] !== 'function') {
      throw new Error('source.' + fn + ' is not a function');
    }
    return $call;
  }).then(function (result) {
    post('sourceResult', {
      callId: callId,
      value: JSON.stringify(result === undefined ? null : result),
    });
  }, function (e) {
    post('sourceError', {
      callId: callId,
      message: String(e && e.message || e),
      stack: String(e && e.stack || ''),
    });
  });
})();
''';
}

final RegExp _scriptLocation = RegExp(r'mangastash-source\.js:(\d+):(\d+)');

({int line, int column})? parseScriptLocation(String stack) {
  final match = _scriptLocation.firstMatch(stack);
  if (match == null) return null;
  return (line: int.parse(match.group(1)!), column: int.parse(match.group(2)!));
}
