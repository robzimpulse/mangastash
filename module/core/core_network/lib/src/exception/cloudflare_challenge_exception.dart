// CloudflareChallengeException plus the recrawl helpers the UI keys its
// "Open Debug Browser" action off: [isRecrawlableError] / [recrawlUrlOf]
// accept page-level failures that carry the URL to reopen — a parse failure,
// a Cloudflare challenge, or (issue #115) a source script failure on a loaded
// page (SourceScriptException with a url; URL-builder runs on the blank page
// have none and are not recrawlable).
//
// Usage: `if (isRecrawlableError(e)) recrawl(url: recrawlUrlOf(e)!)`.
import '../script/source_script_exception.dart';
import 'failed_parsing_html_exception.dart';

/// Thrown when a headless webview load ends on a Cloudflare challenge page
/// (interstitial title or challenge markers in the HTML) instead of the
/// requested content. Distinct from [FailedParsingHtmlException] so callers
/// can surface an actionable "retry / open in browser" message instead of a
/// generic parse failure.
class CloudflareChallengeException implements Exception {
  final String url;

  CloudflareChallengeException(this.url);

  @override
  String toString() =>
      '$runtimeType : Cloudflare challenge page at $url — the site is '
      'blocking automated access; retrying or opening the page in a browser '
      'may clear it';
}

/// Whether [error] is one the UI answers with the "Open Debug Browser"
/// action — a page that failed to parse, was blocked by a Cloudflare
/// challenge, or whose source script failed on the loaded page (e.g. a
/// `ctx.waitFor` timeout on an interstitial). All carry a `.url` to recrawl.
bool isRecrawlableError(Object? error) {
  return recrawlUrlOf(error) != null;
}

/// The URL to reopen in the debug browser for [error], or null when the
/// error is not recrawlable (see [isRecrawlableError]).
String? recrawlUrlOf(Object? error) {
  if (error is FailedParsingHtmlException) return error.url;
  if (error is CloudflareChallengeException) return error.url;
  if (error is SourceScriptException) return error.url;
  return null;
}
