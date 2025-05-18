import 'package:collection/collection.dart';
import 'package:html/dom.dart';

class AsuraScanChapterImageHtmlParser {

  final Document root;

  AsuraScanChapterImageHtmlParser({required this.root});

  List<String> get images {
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