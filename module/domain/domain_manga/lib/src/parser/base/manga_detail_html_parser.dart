import 'package:entity_manga/entity_manga.dart';

import 'base_html_parser.dart';

abstract class MangaDetailHtmlParser extends BaseHtmlParser {
  Manga? get mangas;
  MangaDetailHtmlParser({required super.root});
}