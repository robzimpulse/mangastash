import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'manga_scrapped.dart';

abstract class SourceExternal {
  String get name;
  String get iconUrl;
  String get baseUrl;

  GetMangaUseCase get getMangaUseCase;
  GetChapterUseCase get getChapterImageUseCase;
  SearchMangaUseCase get searchMangaUseCase;
  SearchChapterUseCase get searchChapterUseCase;
}

abstract class GetMangaUseCase {
  List<String> get scripts;
  Future<MangaScrapped> parse({required Document root});
}

abstract class GetChapterUseCase {
  List<String> get scripts;
  Future<List<String>> parse({required Document root});
}

abstract class SearchMangaUseCase {
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required Document root});
  Future<bool?> haveNextPage({required Document root});
}

abstract class SearchChapterUseCase {
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required Document root});
}