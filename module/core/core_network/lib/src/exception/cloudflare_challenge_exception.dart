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
