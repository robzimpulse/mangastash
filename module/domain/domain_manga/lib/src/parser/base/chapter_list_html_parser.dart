import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:html/dom.dart';

import '../asura_scan_chapter_list_html_parser.dart';
import '../manga_clash_chapter_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class ChapterListHtmlParser extends BaseHtmlParser {
  Future<List<ChapterScrapped>> get chapters;
  ChapterListHtmlParser({required super.root});

  factory ChapterListHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanChapterListHtmlParser(root: root);
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashChapterListHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}
