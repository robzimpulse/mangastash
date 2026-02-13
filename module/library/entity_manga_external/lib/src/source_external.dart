import 'package:eval_annotation/eval_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'chapter_scrapped.dart';
import 'html_document.dart';
import 'manga_scrapped.dart';

@Bind()
abstract class SourceExternal {
  String get name;
  String get iconUrl;
  String get baseUrl;

  GetMangaUseCase get getMangaUseCase;
  GetChapterImageUseCase get getChapterImageUseCase;

  SearchMangaExternalUseCase get searchMangaUseCase;
  SearchChapterExternalUseCase get searchChapterUseCase;
}

@Bind()
abstract class GetMangaUseCase {
  List<String> get scripts;
  Future<MangaScrapped> parse({required HtmlDocument root});
}

@Bind()
abstract class GetChapterImageUseCase {
  List<String> get scripts;
  Future<List<String>> parse({required HtmlDocument root});
}

@Bind()
abstract class SearchMangaExternalUseCase {
  List<String> get scripts;
  String url({required SearchMangaParameter parameter});
  Future<List<MangaScrapped>> parse({required HtmlDocument root});
  Future<bool?> haveNextPage({required HtmlDocument root});
}

@Bind()
abstract class SearchChapterExternalUseCase {
  List<String> get scripts;
  Future<List<ChapterScrapped>> parse({required HtmlDocument root});
}