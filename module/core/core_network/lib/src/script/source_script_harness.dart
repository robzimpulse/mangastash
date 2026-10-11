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
///      `sourceError {callId, message, stack[, line, column]}`. `line`/`column`
///      are the numeric position JavaScriptCore (iOS) puts on the thrown Error
///      because its stack for eval'd code has no file/line; they count from the
///      eval'd text, i.e. the script's own line 1, so they equal editor lines.
///      They are omitted when absent, beyond the script's last line (errors
///      raised by ctx helpers or the harness carry harness positions), for a
///      SyntaxError of the script itself (JavaScriptCore offsets it by the line
///      of the eval call) and for the harness's own
///      `source.<function> is not a function` rejection.
///      Serialising the result and posting it happen inside the promise chain,
///      ahead of a final `.catch`, so a throw there (circular structure, BigInt, a failing post) is also
///      reported as `sourceError`; a result that stringifies to `undefined`
///      (undefined, function, symbol) is posted as `"null"`.
/// [parseScriptLocation] extracts `line:column` of the first script frame from
/// a WebKit (`fn@mangastash-source.js:12:9`) or Chromium
/// (`at fn (mangastash-source.js:7:15)`) stack.
/// Usage: the runner evaluates `buildSourceHarness(...)` in the page, awaits the
/// handler call, and on `sourceError` feeds `stack` to [parseScriptLocation]
/// and falls back to the posted `line`/`column`.
/// Generated JS sticks to ES2017 plus spread (iOS 13 WebKit).
library;

import 'dart:convert';

/// JSON literal that is also safe as a JS string literal (U+2028/2029 escaped).
String _literal(Object? value) {
  return jsonEncode(
    value,
  ).replaceAll('\u2028', r'\u2028').replaceAll('\u2029', r'\u2029');
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
    var source;
    try {
      source = (0, eval)(code + '\\n;source;\\n//# sourceURL=mangastash-source.js');
    } catch (err) {
      // JavaScriptCore adds the line of the eval call to a SyntaxError's
      // line, so it points into the harness, not the script.
      if (err && err.name === 'SyntaxError') err.fromHarness = true;
      throw err;
    }
    if (source === null || source === undefined || typeof source[fn] !== 'function') {
      var missing = new Error('source.' + fn + ' is not a function');
      missing.fromHarness = true;
      throw missing;
    }
    return $call;
  }).then(function (result) {
    // Inside the chain on purpose: JSON.stringify can throw (circular
    // structure, BigInt) and so can the post itself; both must reach the
    // .catch below as a sourceError instead of an unhandled rejection that
    // leaves the runner waiting for its timeout. undefined, functions and
    // symbols stringify to undefined, which is reported as JSON "null".
    var json = JSON.stringify(result);
    post('sourceResult', {
      callId: callId,
      value: json === undefined ? 'null' : json,
    });
  }).catch(function (e) {
    var payload = {
      callId: callId,
      message: String(e && e.message || e),
      stack: String(e && e.stack || ''),
    };
    // JavaScriptCore: no file/line in the stack of eval'd code, but numeric
    // line/column on the Error (relative to the eval'd text = script line 1).
    if (e && !e.fromHarness && typeof e.line === 'number' &&
        e.line >= 1 && e.line <= code.split('\\n').length) {
      payload.line = e.line;
      if (typeof e.column === 'number') payload.column = e.column;
    }
    post('sourceError', payload);
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
