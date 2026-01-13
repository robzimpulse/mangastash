import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../asura_scan_tag_list_html_parser.dart';
import '../mangaclash_tag_list_html_parser.dart';
import 'base_html_parser.dart';

abstract class TagListHtmlParser extends BaseHtmlParser {
  Future<List<Tag>> get tags;

  TagListHtmlParser({required super.root});

  factory TagListHtmlParser.forSource({
    required Document root,
    required SourceEnum source,
  }) {
    if (SourceEnum.asurascan == source) {
      return AsuraScanTagListHtmlParser(root: root);
    }

    if (SourceEnum.mangaclash == source) {
      return MangaClashTagListHtmlParser(root: root);
    }

    throw UnimplementedError();
  }
}
