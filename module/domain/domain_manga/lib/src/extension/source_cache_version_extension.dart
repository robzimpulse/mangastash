// Cache identity of a source's scripted output (issue #115, Review Focus 5).
//
// Purpose: the 30-minute browse/search and chapter-list caches of
// SearchMangaUseCase / SearchChapterUseCase persist results derived from a
// script, but were keyed by the request parameters only, so after the user
// edited and saved the script the screens kept serving the OLD script's
// results until a manual refresh. [SourceCacheVersion.cacheVersion] is the
// stable SHA-1 of the script's code (empty for MangaDex, whose results do not
// depend on a script); the use cases append it to their cache keys, so a saved
// edit changes the key and the old entry is simply never read again (it
// expires by itself, and `clear` still removes it, see [stripCacheVersion]).
//
// Usage:
//   final key = '${parameter.toJsonString()}${source?.cacheVersion ?? ''}';
//   final json = stripCacheVersion(key);   // back to the parameter JSON
// The scraped-detail use cases (GetManga/GetChapter/GetTags) persist into
// the DAOs instead of a keyed cache and are refreshed explicitly, so they
// are intentionally not versioned: an edit must not wipe library data.
import 'package:core_network/core_network.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../sources/script_source_external.dart';

extension SourceCacheVersion on SourceExternal {
  /// `@<sha1 of the script code>` for scripted sources, `''` otherwise.
  String get cacheVersion {
    final source = this;
    if (source is! ScriptSourceExternal) return '';
    return '@${sourceScriptCodeHash(source.script.code)}';
  }
}

/// The parameter JSON inside a cache [key] built as `<json><cacheVersion>`
/// (a key without a version is returned unchanged). The JSON always ends with
/// `}`, so everything after its last `}` is the version; a key without any
/// `}` is not a versioned key and is returned unchanged too, so callers can
/// at least try to parse it (and skip it) instead of receiving `''`.
String stripCacheVersion(String key) {
  final i = key.lastIndexOf('}');
  return i < 0 ? key : key.substring(0, i + 1);
}
