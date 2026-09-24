import '../exception/cloudflare_challenge_exception.dart';

/// Cloudflare challenge/block pages seen instead of the requested content.
/// Detection matches on title and content markers — Cloudflare ships several
/// variants ("Just a moment...", "Attention Required!", "Access denied",
/// managed/JS challenges) and a single exact title match misses them all.
const List<String> _challengeTitles = [
  'just a moment',
  'attention required',
  'access denied',
  'checking your browser',
  'please wait',
  'ddos protection by',
];

/// Markers that only occur on challenge pages, not on ordinary content that
/// merely mentions Cloudflare.
const List<String> _challengeHtmlMarkers = [
  '/cdn-cgi/challenge-platform/',
  'checking your browser before accessing',
  'cf-browser-verification',
  'cf_chl_opt',
  'ray id</', // challenge footer row; a plain link to cloudflare.com won't hit
];

/// Whether the loaded page [title]/[html] is a Cloudflare challenge or block
/// page rather than real content.
bool isCloudflareChallenge({String? title, String? html}) {
  final normalizedTitle = title?.trim().toLowerCase();

  if (normalizedTitle != null) {
    for (final candidate in _challengeTitles) {
      if (normalizedTitle.contains(candidate)) return true;
    }
  }

  if (html != null && html.isNotEmpty) {
    final normalizedHtml = html.toLowerCase();
    for (final marker in _challengeHtmlMarkers) {
      if (normalizedHtml.contains(marker)) return true;
    }
  }

  return false;
}

/// Runs [attempt] until it yields a non-challenge page or [attemptCount] is
/// exhausted, waiting [delay] between attempts — a challenge page sometimes
/// clears on a plain reload. Non-challenge failures propagate untouched.
Future<(String, String?)> fetchWithCloudflareRetry({
  required String url,
  required int attemptCount,
  required Future<void> Function(Duration) delay,
  required Future<(String, String?)> Function() attempt,
}) async {
  for (var i = 0; i < attemptCount; i++) {
    if (i > 0) await delay(Duration(seconds: 2));
    final (html, title) = await attempt();

    if (!isCloudflareChallenge(title: title, html: html)) {
      return (html, title);
    }
  }

  throw CloudflareChallengeException(url);
}
