import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'manga_scrapped.dart';
import 'tag_scrapped.dart';

abstract class SourceExternal {
  String get name;
  String get iconUrl;
  String get baseUrl;
  bool get builtIn => false;

  GetMangaSourceExternalUseCase get getMangaUseCase;
  GetChapterImageSourceExternalUseCase get getChapterImageUseCase;
  SearchMangaSourceExternalUseCase get searchMangaUseCase;
  ListChapterSourceExternalUseCase get listChapterUseCase;
  ListTagSourceExternalUseCase get listTagUseCase;
}

abstract class GetMangaSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;

  /// CSS selectors that must each match at least one element before the
  /// HTML snapshot is cached; the fetch fails instead of caching a broken
  /// page. Empty (default) means no readiness requirement.
  List<String> get readyWhenSelectors => [];
  Future<MangaScrapped> parse({required Document root});
}

abstract class GetChapterImageSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;

  /// See [GetMangaSourceExternalUseCase.readyWhenSelectors].
  List<String> get readyWhenSelectors => [];
  Future<List<String>> parse({required Document root});
}

abstract class SearchMangaSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;

  /// See [GetMangaSourceExternalUseCase.readyWhenSelectors].
  List<String> get readyWhenSelectors => [];
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required Document root, String? searchTerm});
  Future<bool?> haveNextPage({required Document root});
}

abstract class ListChapterSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;

  /// See [GetMangaSourceExternalUseCase.readyWhenSelectors].
  List<String> get readyWhenSelectors => [];
  Future<List<ChapterScrapped>> parse({required Document root});
}

abstract class ListTagSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;

  /// See [GetMangaSourceExternalUseCase.readyWhenSelectors].
  List<String> get readyWhenSelectors => [];
  Future<List<TagScrapped>> parse({required Document root});

  /// The page to open for the tag list, when it differs from the search
  /// page — null falls back to `searchMangaUseCase.url(page: 1)`, which is
  /// where most sources list their genres. Override when the tag list
  /// lives elsewhere: that fallback is whatever the search URL resolves
  /// to — for WeebCentral a `/search/data` fragment with zero checkboxes,
  /// so it points at `/search` (issue #163). Note the deliberate shape
  /// difference from the chapter-list hook: tags are one global page
  /// (`url` getter), chapters are per-manga (`url({webUrl})` method).
  String? get url => null;
}
