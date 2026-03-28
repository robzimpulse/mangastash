import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'manga_scrapped.dart';

abstract class SourceExternal {
  String get name;
  String get iconUrl;
  String get baseUrl;

  GetMangaParser get getMangaUseCase;
  GetChapterImageParser get getChapterImageUseCase;
  SearchMangaParser get searchMangaUseCase;
  SearchChapterParser get searchChapterUseCase;
  SearchMangaUrl get searchMangaUrl;
}

abstract class GetMangaParser {
  List<String> get scripts;
  Future<MangaScrapped> parse({required Document root});
}

abstract class GetChapterImageParser {
  List<String> get scripts;
  Future<List<String>> parse({required Document root});
}

abstract class SearchMangaParser {
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required Document root});
  Future<bool?> haveNextPage({required Document root});
}

abstract class SearchChapterParser {
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required Document root});
}

abstract class SearchMangaUrl {
  String url({required SearchMangaParameter parameter});
}