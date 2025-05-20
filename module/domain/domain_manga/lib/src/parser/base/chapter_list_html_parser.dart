import 'package:entity_manga/entity_manga.dart';

import 'base_html_parser.dart';

abstract class ChapterListHtmlParser extends BaseHtmlParser {
  List<MangaChapter> get chapters;
  ChapterListHtmlParser({required super.root});
}