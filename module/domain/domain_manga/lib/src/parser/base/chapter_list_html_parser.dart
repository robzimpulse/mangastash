import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_chapter_list_html_parser.dart';
import '../manga_clash_chapter_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class ChapterListHtmlParser extends BaseHtmlParser {
  List<Chapter> get chapters;
  ChapterListHtmlParser({required super.root});

  factory ChapterListHtmlParser.forSource({
    required Document root,
    required MangaSourceEnum source,
  }) {
    return switch (source) {
      MangaSourceEnum.mangadex => throw UnimplementedError(),
      MangaSourceEnum.asurascan => AsuraScanChapterListHtmlParser(root: root),
      MangaSourceEnum.mangaclash => MangaClashChapterListHtmlParser(root: root),
    };
  }
}