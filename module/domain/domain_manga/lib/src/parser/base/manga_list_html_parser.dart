import 'package:entity_manga/entity_manga.dart';

import 'base_html_parser.dart';

abstract class MangaListHtmlParser extends BaseHtmlParser {
  List<Manga> get mangas;
  MangaListHtmlParser({required super.root});
}