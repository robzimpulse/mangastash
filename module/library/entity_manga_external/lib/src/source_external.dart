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
  List<String> get scripts;
  Future<MangaScrapped> parse({required Document root});
}

abstract class GetChapterImageSourceExternalUseCase {
  List<String> get scripts;
  bool get forceLoad;
  Future<List<String>> parse({required Document root});
}

abstract class SearchMangaSourceExternalUseCase {
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required Document root});
  Future<bool?> haveNextPage({required Document root});
}

abstract class ListChapterSourceExternalUseCase {
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required Document root});
}

abstract class ListTagSourceExternalUseCase {
  List<String> get scripts;
  Future<List<TagScrapped>> parse({required Document root});
}
