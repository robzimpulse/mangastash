import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import 'chapter_image_html_parser.dart';
import 'chapter_list_html_parser.dart';
import 'manga_detail_html_parser.dart';
import 'manga_list_html_parser.dart';

class BaseHtmlParser {
  final Document root;

  BaseHtmlParser({required this.root});

  factory BaseHtmlParser.forSource({
    required Document root,
    required MangaSourceEnum source,
    required BaseHtmlParserMethod method,
  }) {
    return switch (method) {
      BaseHtmlParserMethod.chapterImage => ChapterImageHtmlParser.forSource(
          root: root,
          source: source,
        ),
      BaseHtmlParserMethod.chapterList => ChapterListHtmlParser.forSource(
          root: root,
          source: source,
        ),
      BaseHtmlParserMethod.mangaDetail => MangaDetailHtmlParser.forSource(
          root: root,
          source: source,
        ),
      BaseHtmlParserMethod.mangaList => MangaListHtmlParser.forSource(
          root: root,
          source: source,
        ),
    };
  }
}

enum BaseHtmlParserMethod {
  chapterImage,
  chapterList,
  mangaDetail,
  mangaList;
}
