import 'package:collection/collection.dart';

import 'base/chapter_image_html_parser.dart';

class MangaClashChapterImageHtmlParser extends ChapterImageHtmlParser {
  MangaClashChapterImageHtmlParser({
    required super.root,
    required super.converterCacheManager,
  });

  @override
  Future<List<String>> get images async {
    final region = root.querySelector('.reading-content');
    final containers = region?.querySelectorAll('img') ?? [];
    final List<(num, String)> data = [];
    for (final image in containers) {
      final id = image.attributes['id']?.split('-').lastOrNull;
      if (id == null) continue;
      final url = image.attributes['data-src'];
      final index = int.tryParse(id);
      if (index == null || url == null) continue;
      data.add((index, url.trim()));
    }
    return data.sortedBy((e) => e.$1).map((e) => e.$2).toList();
  }
}
