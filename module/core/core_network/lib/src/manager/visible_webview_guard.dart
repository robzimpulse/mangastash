/// Counts the visible (user-facing) in-app webview sessions that are open.
///
/// Purpose: on Android every WebView of the app shares one renderer process,
/// and `HeadlessWebviewManager` terminates that renderer when a script run
/// times out (see its `_terminateRenderer`). The visible webview screens of
/// `log_box_in_app_webview_logger` (opened through `LogBox.webview`, e.g. by
/// "Open Debug Browser") register no `onRenderProcessGone`, so Android would
/// kill the whole app with the renderer. The manager therefore skips the
/// termination while [isOpen] is true.
/// Usage: wrap every `logBox.webview(...)` call in [track]:
/// `await guard.track(() => logBox.webview(context: context, uri: uri));`
/// (the count is lowered in a `finally`, so a throwing or cancelled session
/// cannot leave the guard stuck). `CoreNetworkRegistrar` registers one
/// instance, shared with `HeadlessWebviewManager`. Sessions opened some other
/// way (the log inspector's own webview entries) cannot be tracked here; the
/// Android `MainActivity` additionally refuses to terminate while a WebView
/// is attached to its window.
library;

class VisibleWebviewGuard {
  int _open = 0;

  /// Number of tracked visible webview sessions currently open.
  int get openCount => _open;

  /// Whether at least one tracked visible webview session is open.
  bool get isOpen => _open > 0;

  /// Runs [session] (the visible webview call) with the guard raised.
  Future<T> track<T>(Future<T> Function() session) async {
    _open++;
    try {
      return await session();
    } finally {
      _open--;
    }
  }
}
