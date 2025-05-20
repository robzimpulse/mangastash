import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_chapter_image_html_parser.dart';
import '../manga_clash_chapter_image_html_parser.dart';
import 'base_html_parser.dart';

abstract class ChapterImageHtmlParser extends BaseHtmlParser {
  List<String> get images;
  ChapterImageHtmlParser({required super.root});

  factory ChapterImageHtmlParser.forSource({
    required Document root,
    required MangaSourceEnum source,
  }) {
    return switch (source) {
      MangaSourceEnum.mangadex => throw UnimplementedError(),
      MangaSourceEnum.asurascan => AsuraScanChapterImageHtmlParser(root: root),
      MangaSourceEnum.mangaclash => MangaClashChapterImageHtmlParser(root: root),
    };
  }
}