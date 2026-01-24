import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../asura_scan_chapter_image_html_parser.dart';
import '../manga_clash_chapter_image_html_parser.dart';
import 'base_html_parser.dart';

abstract class ChapterImageHtmlParser extends BaseHtmlParser {
  Future<List<String>> get images;
  ChapterImageHtmlParser({required super.root});

  factory ChapterImageHtmlParser.forSource({
    required HtmlDocument root,
    required SourceEnum source,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanChapterImageHtmlParser(root: root);
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashChapterImageHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}
