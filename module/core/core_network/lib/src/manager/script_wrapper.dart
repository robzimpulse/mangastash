import 'package:html/parser.dart';

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

/// Generates a script that polls until every [selectors] matches at least
/// one element, then reports the outcome over the `flutter_inappwebview`
/// bridge (`scriptReady` handler). Reporting goes through `callHandler`
/// because `evaluateJavascript` does not await JS Promises — the same reason
/// the image pipeline uses handlers. Bounded: after [maxTries] ×
/// [intervalMs] it reports `false` instead of looping forever.
String readinessBeaconScript(
  List<String> selectors, {
  int intervalMs = 250,
  int maxTries = 40,
}) {
  final escaped = [
    for (final selector in selectors) selector.replaceAll("'", r"\'"),
  ];
  return '''
(function(){
  const selectors = ['${escaped.join("', '")}'];
  const maxTries = $maxTries;
  const intervalMs = $intervalMs;
  let tries = 0;
  const check = () => {
    const ready = selectors.every(s => document.querySelectorAll(s).length > 0);
    if (ready || ++tries >= maxTries) {
      window.flutter_inappwebview.callHandler('scriptReady', ready);
    } else {
      setTimeout(check, intervalMs);
    }
  };
  check();
})()''';
}

/// Whether every selector in [selectors] matches at least one element in
/// [html]. An empty list is trivially satisfied — sources without readiness
/// needs keep today's behavior.
bool readinessSatisfied(String html, List<String> selectors) {
  if (selectors.isEmpty) return true;

  final root = parse(html);
  return selectors.every((selector) {
    try {
      return root.querySelectorAll(selector).isNotEmpty;
    } on Exception {
      return false;
    }
  });
}
