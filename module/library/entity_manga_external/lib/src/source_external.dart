import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'html_document.dart';
import 'manga_scrapped.dart';

abstract class SourceExternal {
  String get name;
  String get iconUrl;
  String get baseUrl;

  GetMangaUseCase get getMangaUseCase;
  GetChapterImageUseCase get getChapterImageUseCase;

  SearchMangaExternalUseCase get searchMangaUseCase;
  SearchChapterExternalUseCase get searchChapterUseCase;
}

abstract class GetMangaUseCase {
  List<String> get scripts;
  Future<MangaScrapped> parse({required HtmlDocument root});
}

abstract class GetChapterImageUseCase {
  List<String> get scripts;
  Future<List<String>> parse({required HtmlDocument root});
}

abstract class SearchMangaExternalUseCase {
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required HtmlDocument root});
  Future<bool?> haveNextPage({required HtmlDocument root});
}

abstract class SearchChapterExternalUseCase {
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required HtmlDocument root});
}