import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_manga_detail_html_parser.dart';
import '../manga_clash_manga_detail_html_parser.dart';
import 'base_html_parser.dart';

abstract class MangaDetailHtmlParser extends BaseHtmlParser {
  Manga get manga;
  MangaDetailHtmlParser({required super.root});

  factory MangaDetailHtmlParser.forSource({
    required Document root,
    required String source,
  }) {
    if (Source.asurascan().name == source) {
      return AsuraScanMangaDetailHtmlParser(root: root);
    }

    if (Source.mangaclash().name == source) {
      return MangaClashMangaDetailHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}