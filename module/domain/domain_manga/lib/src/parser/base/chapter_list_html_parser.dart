import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_chapter_list_html_parser.dart';
import '../manga_clash_chapter_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class ChapterListHtmlParser extends BaseHtmlParser {
  Future<List<Chapter>> get chapters;
  ChapterListHtmlParser({required super.root, required super.storageManager});

  factory ChapterListHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
    required StorageManager storageManager,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanChapterListHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashChapterListHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    throw UnimplementedError();
  }
}
