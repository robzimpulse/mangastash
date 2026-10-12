// HeadlessWebviewUseCase: fetches an image through a headless webview (so the
// request carries the site's cookies and UA) and returns it as a data URL.
// Page scraping moved to RunSourceScriptUseCase with the JS sources (issue
// #115), which removed the old `open` → parsed-DOM entry point.
//
// Usage: `await locator<HeadlessWebviewUseCase>().image(url, headers: h)`.
abstract class HeadlessWebviewUseCase {
  Future<String> image(
    String url, {
    bool useCache = true,
    Map<String, String>? headers,
    Duration? timeout,
  });
}
