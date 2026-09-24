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
/// action — a page that failed to parse or was blocked by a Cloudflare
/// challenge. Both carry a `.url` to recrawl.
bool isRecrawlableError(Object? error) {
  return error is FailedParsingHtmlException ||
      error is CloudflareChallengeException;
}

/// The URL to reopen in the debug browser for [error], or null when the
/// error is not recrawlable (see [isRecrawlableError]).
String? recrawlUrlOf(Object? error) {
  if (error is FailedParsingHtmlException) return error.url;
  if (error is CloudflareChallengeException) return error.url;
  return null;
}
