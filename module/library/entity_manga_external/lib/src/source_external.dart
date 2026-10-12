// The SourceExternal contract (issue #115, spec §7): one manga source as the
// domain layer sees it — metadata plus document-free scraping hooks that return
// the *Scrapped models. Scripted sources implement it with a JS script run in a
// headless webview (`ScriptSourceExternal` in domain_manga); the built-in
// MangaDex source sets [builtIn] and its scraping hooks throw
// `UnimplementedError` (MangaDex goes through manga_dex_api instead).
//
// Usage (scraped sources only, i.e. `!source.builtIn`):
//   final url = await source.searchUrl(parameter: parameter);
//   final page = await source.search(url: url, searchTerm: parameter.title);
//   final detail = await source.manga(url: manga.webUrl!);
//   final rows = await source.chapters(
//     url: await source.chaptersUrl(webUrl: manga.webUrl!),
//   );
//   final images = await source.images(url: chapter.webUrl!);
//   final tags = await source.tags(url: await source.tagsUrl());
// `useCache: false` bypasses the 30-minute result cache of page functions.
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'manga_scrapped.dart';
import 'search_result_scrapped.dart';
import 'tag_scrapped.dart';

abstract class SourceExternal {
  /// Display name and the database key of every row from this source.
  String get name;
  String get iconUrl;
  String get baseUrl;

  /// Whether the source is native (MangaDex) rather than scraped.
  bool get builtIn => false;

  /// URL of the search/browse page for [parameter] (empty title = browse).
  Future<String> searchUrl({required SearchMangaParameter parameter});

  /// Cards (and whether a next page exists) on the search page at [url].
  /// [searchTerm] is the title searched for, for sources that filter
  /// client-side.
  Future<SearchResultScrapped> search({
    required String url,
    String? searchTerm,
    bool useCache = true,
  });

  /// Series details on the series page at [url].
  Future<MangaScrapped> manga({required String url, bool useCache = true});

  /// The page holding the chapter list of the series at [webUrl]; usually
  /// [webUrl] itself.
  Future<String> chaptersUrl({required String webUrl});

  /// Chapter rows on the chapter-list page at [url].
  Future<List<ChapterScrapped>> chapters({
    required String url,
    bool useCache = true,
  });

  /// Image URLs, in reading order, on the reader page at [url].
  Future<List<String>> images({required String url, bool useCache = true});

  /// The page listing the source's genres.
  Future<String> tagsUrl();

  /// Genres on the tag page at [url].
  Future<List<TagScrapped>> tags({required String url, bool useCache = true});
}
