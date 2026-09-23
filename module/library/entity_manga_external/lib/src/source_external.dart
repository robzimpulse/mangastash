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
}
