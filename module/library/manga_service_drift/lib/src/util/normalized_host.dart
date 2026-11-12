// Normalised-URL-host helper shared by the moved-source feature (issue #206).
//
// `normalizedHostOf(url)` extracts the host of [url] in a form that compares
// equal across cosmetic differences: lowercased, port dropped, and one
// leading `www.` stripped. It returns null for a null/blank URL or one with
// no parseable host (relative paths, garbage strings).
//
// Usage: import via `package:manga_service_drift/manga_service_drift.dart`
// (or the relative path inside this package) and compare two hosts with
// `normalizedHostOf(a) == normalizedHostOf(b)`. Consumers: the moved-source
// predicate in domain_manga and MangaDao's title+source fallback — keep this
// the single definition of "same host".
String? normalizedHostOf(String? url) {
  if (url == null || url.isEmpty) return null;

  final host = Uri.tryParse(url)?.host;
  if (host == null || host.isEmpty) return null;

  final lowered = host.toLowerCase();
  if (lowered.startsWith('www.')) return lowered.substring('www.'.length);

  return lowered;
}
