import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_chapter_list_html_parser.dart';
import '../manga_clash_chapter_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class ChapterListHtmlParser extends BaseHtmlParser {
  Future<List<Chapter>> get chapters;
  ChapterListHtmlParser({required super.root, required super.converterCacheManager});

  factory ChapterListHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
    required ConverterCacheManager converterCacheManager,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanChapterListHtmlParser(
        root: root,
        converterCacheManager: converterCacheManager,
      );
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashChapterListHtmlParser(
        root: root,
        converterCacheManager: converterCacheManager,
      );
    }

    throw UnimplementedError();
  }
}
