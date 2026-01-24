import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../asura_scan_manga_list_html_parser.dart';
import '../manga_clash_manga_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class MangaListHtmlParser extends BaseHtmlParser {
  Future<List<Manga>> get mangas;
  Future<bool?> get haveNextPage;
  MangaListHtmlParser({required super.root});

  factory MangaListHtmlParser.forSource({
    required HtmlDocument root,
    required SourceEnum source,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanMangaListHtmlParser(root: root);
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashMangaListHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}
