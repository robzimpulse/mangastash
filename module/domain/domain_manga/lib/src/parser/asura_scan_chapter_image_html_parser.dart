import 'package:collection/collection.dart';

import 'base/chapter_image_html_parser.dart';

class AsuraScanChapterImageHtmlParser extends ChapterImageHtmlParser {
  AsuraScanChapterImageHtmlParser({
    required super.root,
    required super.storageManager,
  });

  @override
  Future<List<String>> get images async {
    final region = root.querySelector(
      'div.py-8.-mx-5.flex.flex-col.items-center.justify-center',
    );
    final containers = region?.querySelectorAll('img') ?? [];
    final List<(num, String)> data = [];
    for (final image in containers) {
      final id = image.attributes['alt']?.split(' ').lastOrNull;
      if (id == null) continue;
      final url = image.attributes['src'];
      final index = int.tryParse(id);
      if (index == null || url == null) continue;
      data.add((index, url.trim()));
    }
    return data.sortedBy((e) => e.$1).map((e) => e.$2).toList();
  }
}
