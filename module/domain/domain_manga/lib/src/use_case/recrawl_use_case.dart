// RecrawlUseCase: opens [url] in the visible in-app webview so the user can
// pass a Cloudflare challenge (or just look at the page), then — once the
// webview is closed — evicts every cached script result for [url] (issue #115)
// so the next headless run re-fetches the page with the cookies the visible
// webview obtained. Nothing is written into any cache. The visible session is
// tracked by the shared `VisibleWebviewGuard` so the headless runner never
// terminates the (shared, Android) renderer under it.
//
// Usage: `await recrawlUseCase.execute(context: context, url: url);` then
// refresh the screen (callers re-run their use case with `useCache: false`).
// `openWebview` replaces the visible webview call in tests.
import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:flutter/material.dart';

class RecrawlUseCase {
  final LogBox _logBox;
  final RunSourceScriptUseCase _runner;
  final VisibleWebviewGuard _guard;
  final Future<void> Function(BuildContext context, Uri uri)? _openWebview;

  RecrawlUseCase({
    required this._logBox,
    required this._runner,
    required this._guard,
    this._openWebview,
  });

  Future<void> execute({
    required BuildContext context,
    required String url,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await _guard.track(
      () =>
          _openWebview?.call(context, uri) ??
          _logBox.webview(context: context, uri: uri),
    );
    await _runner.evict(url: url);
  }
}
