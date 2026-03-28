import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'manga_scrapped.dart';

abstract class SourceExternal {
  String get name;
  String get iconUrl;
  String get baseUrl;
  bool get builtIn => false;

  GetMangaSourceExternalUseCase get getMangaUseCase;
  GetChapterSourceExternalUseCase get getChapterImageUseCase;
  SearchMangaSourceExternalUseCase get searchMangaUseCase;
  SearchChapterSourceExternalUseCase get searchChapterUseCase;
}

abstract class GetMangaSourceExternalUseCase {
  List<String> get scripts;
  Future<MangaScrapped> parse({required Document root});
}

abstract class GetChapterSourceExternalUseCase {
  List<String> get scripts;
  Future<List<String>> parse({required Document root});
}

abstract class SearchMangaSourceExternalUseCase {
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required Document root});
  Future<bool?> haveNextPage({required Document root});
}

abstract class SearchChapterSourceExternalUseCase {
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required Document root});
}