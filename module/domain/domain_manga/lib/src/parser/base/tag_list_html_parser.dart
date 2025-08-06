import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_tag_list_html_parser.dart';
import '../mangaclash_tag_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class TagListHtmlParser extends BaseHtmlParser {
  Future<List<Tag>> get tags;

  TagListHtmlParser({required super.root, required super.storageManager});

  factory TagListHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
    required StorageManager storageManager,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanTagListHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashTagListHtmlParser(
        root: root,
        storageManager: storageManager,
      );
    }

    throw UnimplementedError();
  }
}
