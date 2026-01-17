import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../asura_scan_manga_detail_html_parser.dart';
import '../manga_clash_manga_detail_html_parser.dart';
import 'base_html_parser.dart';

abstract class MangaDetailHtmlParser extends BaseHtmlParser {
  Future<MangaScrapped> get manga;
  MangaDetailHtmlParser({required super.root});

  factory MangaDetailHtmlParser.forSource({
    required HtmlDocument root,
    required SourceEnum source,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanMangaDetailHtmlParser(root: root);
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashMangaDetailHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}
