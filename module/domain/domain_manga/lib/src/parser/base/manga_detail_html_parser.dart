import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_manga_detail_html_parser.dart';
import '../manga_clash_manga_detail_html_parser.dart';
import 'base_html_parser.dart';

abstract class MangaDetailHtmlParser extends BaseHtmlParser {
  Future<Manga> get manga;
  MangaDetailHtmlParser({required super.root, required super.storageManager});

  factory MangaDetailHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
    required StorageManager storageManager,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanMangaDetailHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashMangaDetailHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    throw UnimplementedError();
  }
}
