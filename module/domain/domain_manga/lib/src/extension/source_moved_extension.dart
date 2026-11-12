// The moved-source predicate (issue #206): `SourceMoved.movedHostOf` decides,
// offline and on read, whether a stored URL belongs to a host the source no
// longer serves. A scraped source is "moved" for a URL when the URL's
// normalised host (see `normalizedHostOf`) is neither the source's baseUrl
// host nor one of its script header's `hosts`. Built-in sources (MangaDex)
// and URLs without a parseable host are never moved.
//
// One shared definition: the gated use cases (GetMangaUseCase,
// SearchChapterUseCase, GetChapterUseCase) and the UI mark (detail banner,
// library badge via the `Sources` facade) all call this same extension, so a
// saved source edit changes the answer at once and putting the old host back
// into `hosts` clears the mark with no restart.
//
// Usage:
//   final host = source.movedHostOf(manga.webUrl);
//   if (host != null) ... // frozen: serve stored data only, mark the UI
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

extension SourceMoved on SourceExternal {
  /// The normalised host of [url] when [this] source no longer lists it, so
  /// data stored on it is frozen; null when the URL is still served (or
  /// cannot be judged: built-in source, null/blank/unparseable URL).
  String? movedHostOf(String? url) {
    if (builtIn) return null;

    final host = normalizedHostOf(url);
    if (host == null) return null;

    final knownHosts = <String?>{
      normalizedHostOf(baseUrl),
      // Header hosts are bare names; run them through the same normaliser so
      // `WWW.Old.com` in the header compares equal to a stored `old.com` URL.
      ...hosts.map((entry) => normalizedHostOf('https://$entry')),
    };

    return knownHosts.contains(host) ? null : host;
  }
}
