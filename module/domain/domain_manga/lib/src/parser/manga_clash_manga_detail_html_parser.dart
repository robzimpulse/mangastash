import 'package:entity_manga/entity_manga.dart';

import 'base/manga_detail_html_parser.dart';

class MangaClashMangaDetailHtmlParser extends MangaDetailHtmlParser {
  MangaClashMangaDetailHtmlParser({required super.root});

  @override
  Manga get manga {
    final description = root
        .querySelector('div.description-summary')
        ?.querySelectorAll('p')
        .map((e) => e.text.trim())
        .join('\n\n');

    return Manga(description: description);
  }
}
