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
    required String source,
  }) {
    if (Source.asurascan().name == source) {
      return AsuraScanChapterListHtmlParser(root: root);
    }

    if (Source.mangaclash().name == source) {
      return MangaClashChapterListHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}