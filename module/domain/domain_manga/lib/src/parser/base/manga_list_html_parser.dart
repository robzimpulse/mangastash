import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_manga_list_html_parser.dart';
import '../manga_clash_manga_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class MangaListHtmlParser extends BaseHtmlParser {
  Future<List<Manga>> get mangas;
  Future<bool?> get haveNextPage;
  MangaListHtmlParser({required super.root, required super.storageManager});

  factory MangaListHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
    required StorageManager storageManager,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanMangaListHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashMangaListHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    throw UnimplementedError();
  }
}
