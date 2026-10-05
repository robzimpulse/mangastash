// URL-query codec for [ChapterConfig] (issue #130).
//
// The chapter-config bottom sheet route receives its config through
// `state.extra`, which is null whenever the route is rebuilt from a URL
// (deep link, hot restart, process restoration). Encoding the config into
// the route's query parameters keeps the sheet functional in those cases.
//
// Usage:
// - Push side: `context.push(chapterConfigLocation(config), extra: config)`
//   — `chapterConfigLocation` builds `<path>?downloaded=…&display=…`.
// - Route side: `state.extra.castOrNull<ChapterConfig>() ??
//   chapterConfigFromQueryParameters(state.uri.queryParameters)`.
//
// Decoding never throws: unknown or missing values fall back to the
// [ChapterConfig] defaults so a malformed link still opens a usable sheet.
import 'package:entity_manga/entity_manga.dart';

/// Query keys used by the codec. Kept short but explicit.
const _keyDownloaded = 'downloaded';
const _keyUnread = 'unread';
const _keyDisplay = 'display';
const _keySortOption = 'sortOption';
const _keySortOrder = 'sortOrder';

Map<String, String> chapterConfigToQueryParameters(ChapterConfig config) {
  return {
    if (config.downloaded != null) _keyDownloaded: config.downloaded.toString(),
    if (config.unread != null) _keyUnread: config.unread.toString(),
    _keyDisplay: config.display.name,
    _keySortOption: config.sortOption.name,
    _keySortOrder: config.sortOrder.name,
  };
}

/// Decodes a [ChapterConfig] from query parameters. An empty map (a bare
/// deep link with no config encoded) decodes to null — the sheet's
/// `config ?? const ChapterConfig()` show-all default must apply, because
/// a config with null booleans is an ACTIVE read/not-downloaded filter
/// (review on #176).
ChapterConfig? chapterConfigFromQueryParameters(Map<String, String> queries) {
  if (queries.isEmpty) return null;
  return ChapterConfig(
    downloaded: _readBool(queries[_keyDownloaded]),
    unread: _readBool(queries[_keyUnread]),
    display: _readEnum(
      queries[_keyDisplay],
      ChapterDisplayEnum.values,
      ChapterDisplayEnum.title,
    ),
    sortOption: _readEnum(
      queries[_keySortOption],
      ChapterSortOptionEnum.values,
      ChapterSortOptionEnum.chapterNumber,
    ),
    sortOrder: _readEnum(
      queries[_keySortOrder],
      ChapterSortOrderEnum.values,
      ChapterSortOrderEnum.desc,
    ),
  );
}

/// Builds the pushable location (`<path>?…`) for [config] over [path].
String chapterConfigLocation(String path, ChapterConfig config) {
  return Uri(
    path: path,
    queryParameters: chapterConfigToQueryParameters(config),
  ).toString();
}

bool? _readBool(String? value) {
  if (value == null) return null;
  if (value.toLowerCase() == 'true') return true;
  if (value.toLowerCase() == 'false') return false;
  return null;
}

T _readEnum<T extends Enum>(String? value, List<T> values, T fallback) {
  if (value != null) {
    for (final entry in values) {
      if (entry.name == value) return entry;
    }
  }
  return fallback;
}
