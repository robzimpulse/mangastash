// Unit tests for the ChapterConfig URL-query codec (issue #130):
// bottom-sheet routes lose `state.extra` when rebuilt from a URL (deep
// link, process restoration), so the chapter-config sheet carries its
// config in query parameters. The codec must round-trip every field
// (including the tri-state booleans — ChapterConfig's constructor
// defaults them to false, but an explicit null means "no filter" and must
// survive), and never throw on malformed input (unknown enum names fall
// back to defaults).
//
// Run with: fvm flutter test test/src/chapter_config_query_test.dart
import 'package:entity_manga/entity_manga.dart';
import 'package:feature_browse/src/chapter_config_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips a fully populated config', () {
    const config = ChapterConfig(
      downloaded: true,
      unread: false,
      display: ChapterDisplayEnum.chapter,
      sortOption: ChapterSortOptionEnum.uploadDate,
      sortOrder: ChapterSortOrderEnum.asc,
    );

    final decoded = chapterConfigFromQueryParameters(
      chapterConfigToQueryParameters(config),
    );

    expect(decoded, config);
  });

  test('round-trips the constructor defaults (false booleans)', () {
    const config = ChapterConfig();

    final decoded = chapterConfigFromQueryParameters(
      chapterConfigToQueryParameters(config),
    );

    // A round-trip always encodes the enum keys, so it never decodes to
    // the empty-query null.
    expect(decoded, isNotNull);
    expect(decoded, config);
    expect(decoded!.downloaded, isFalse);
    expect(decoded.unread, isFalse);
  });

  test('round-trips an explicit-null tri-state as null (no filter)', () {
    final config = const ChapterConfig().copyWith(
      downloaded: () => null,
      unread: () => null,
    );

    final decoded = chapterConfigFromQueryParameters(
      chapterConfigToQueryParameters(config),
    );

    expect(decoded, isNotNull);
    expect(decoded!.downloaded, isNull);
    expect(decoded.unread, isNull);
  });

  test('unknown values fall back to no-filter booleans and default enums', () {
    final decoded = chapterConfigFromQueryParameters(const {
      'downloaded': 'yes',
      'display': 'hologram',
      'sortOption': '',
      'sortOrder': 'sideways',
    });

    final expected = const ChapterConfig(
      display: ChapterDisplayEnum.title,
      sortOption: ChapterSortOptionEnum.chapterNumber,
      sortOrder: ChapterSortOrderEnum.desc,
    ).copyWith(downloaded: () => null, unread: () => null);

    expect(decoded, expected);
  });

  // Review on #176: a bare deep link produces an empty query, and
  // decoding it to explicit-null booleans turned "no config in the URL"
  // into an ACTIVE read/not-downloaded filter
  // (MangaDetailScreenState.filtered treats null unread/downloaded as
  // filters). Empty must decode to null so the sheet falls back to its
  // show-all `const ChapterConfig()` default.
  test('empty query parameters decode to null (the sheet default)', () {
    expect(chapterConfigFromQueryParameters(const {}), isNull);
  });
}
