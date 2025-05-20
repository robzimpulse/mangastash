import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_manga_list_html_parser.dart';
import '../manga_clash_manga_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class MangaListHtmlParser extends BaseHtmlParser {
  List<Manga> get mangas;
  bool? get haveNextPage;
  int? get total;
  MangaListHtmlParser({required super.root});

  factory MangaListHtmlParser.forSource({
    required Document root,
    required MangaSourceEnum source,
  }) {
    return switch (source) {
      MangaSourceEnum.mangadex => throw UnimplementedError(),
      MangaSourceEnum.asurascan => AsuraScanMangaListHtmlParser(root: root),
      MangaSourceEnum.mangaclash => MangaClashMangaListHtmlParser(root: root),
    };
  }
}
