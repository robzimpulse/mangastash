import 'package:entity_manga/entity_manga.dart';

import 'base/chapter_list_html_parser.dart';

class MangaClashChapterListHtmlParser extends ChapterListHtmlParser {
  MangaClashChapterListHtmlParser({required super.root});

  @override
  Future<List<ChapterScrapped>> get chapters async {
    final List<ChapterScrapped> data = [];

    for (final element in root.querySelectorAll('li.wp-manga-chapter')) {
      final url = element.querySelector('a')?.attributes['href'];
      final title = element.querySelector('a')?.text.split('-').lastOrNull;
      final text = element.querySelector('a')?.text.split(' ').map((text) {
        final value = double.tryParse(text);

        if (value != null) {
          final fraction = value - value.truncate();
          if (fraction > 0.0) return value;
        }

        return int.tryParse(text);
      });
      final releaseDate =
          element.querySelector('.chapter-release-date')?.text.trim();
      final chapter = text?.nonNulls.firstOrNull;

      data.add(
        ChapterScrapped(
          title: title?.trim(),
          chapter: chapter != null ? '$chapter' : null,
          readableAtRaw: releaseDate,
          webUrl: url,
        ),
      );
    }
    return data;
  }
}
