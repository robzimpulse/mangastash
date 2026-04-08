import 'package:eval_annotation/eval_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'html_document.dart';
import 'manga_scrapped.dart';
import 'tag_scrapped.dart';

@Bind()
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

@Bind()
abstract class GetMangaSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;
  Future<MangaScrapped> parse({required HtmlDocument root});
}

@Bind()
abstract class GetChapterImageSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;
  Future<List<String>> parse({required HtmlDocument root});
}

@Bind()
abstract class SearchMangaSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required HtmlDocument root});
  Future<bool?> haveNextPage({required HtmlDocument root});
}

@Bind()
abstract class ListChapterSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required HtmlDocument root});
}

@Bind()
abstract class ListTagSourceExternalUseCase {
  Duration? get timeout;
  List<String> get scripts;
  Future<List<TagScrapped>> parse({required HtmlDocument root});
}
