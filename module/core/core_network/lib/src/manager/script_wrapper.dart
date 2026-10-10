// Error-reporting wrapper for scripts injected by HeadlessWebviewManager's
// page fetch (the image pipeline). The readiness beacon helpers that used to
// live here went away with the Dart scrapers (issue #115): JS sources wait for
// their own readiness with `ctx.waitFor`.
//
// Usage: `controller.evaluateJavascript(source: wrapScript(js, index: i))`
// with a `scriptError` JS handler registered on the webview.

/// Wraps [script] so a thrown JS error is reported over the
/// `flutter_inappwebview` bridge instead of vanishing: the manager registers
/// a `scriptError` handler and turns the report into
/// `ScriptEvaluationException`. The wrapper is an async IIFE so it can also
/// await polling scripts.
String wrapScript(String script, {required int index}) {
  return '''
(async function(){
  const scriptIndex = $index;
  try {
$script
  } catch (e) {
    window.flutter_inappwebview.callHandler('scriptError', {script: scriptIndex, error: String(e && e.message || e)});
    throw e;
  }
})()''';
}
