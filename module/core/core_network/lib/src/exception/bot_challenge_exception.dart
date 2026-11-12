/// Exception and predicate for MangaDex edge bot challenge detection.
///
/// Thrown when MangaDex's edge redirects a request to its POWBlock
/// proof-of-work challenge page (`https://mangadex.org/edge/challenge`).
///
/// Usage:
/// Call [isBotChallengeUri] with a response's realUri to detect if a redirect
/// landed on the challenge page, and throw or map to [BotChallengeException].
library;

/// Returns true if [uri] is the MangaDex edge bot challenge page.
bool isBotChallengeUri(Uri uri) {
  return uri.host == 'mangadex.org' && uri.path == '/edge/challenge';
}

/// Thrown when an automated request is blocked by a MangaDex bot challenge page.
class BotChallengeException implements Exception {
  final String url;

  BotChallengeException(this.url);

  @override
  String toString() {
    return '$runtimeType : bot challenge page served for $url — the site blocks automated access from this client';
  }
}
