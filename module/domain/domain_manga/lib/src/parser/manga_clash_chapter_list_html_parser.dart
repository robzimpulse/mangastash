import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';

import 'base/chapter_list_html_parser.dart';

class MangaClashChapterListHtmlParser extends ChapterListHtmlParser {
  MangaClashChapterListHtmlParser({required super.root});

  @override
  List<Chapter> get chapters {
    final List<Chapter> data = [];

    for (final element in root.querySelectorAll('li.wp-manga-chapter')) {
      final url = element.querySelector('a')?.attributes['href'];
      final title = element.querySelector('a')?.text.split('-').lastOrNull;
      final text = element.querySelector('a')?.text.split(' ').map(
        (text) {
          final value = double.tryParse(text);

          if (value != null) {
            final fraction = value - value.truncate();
            if (fraction > 0.0) return value;
          }

          return int.tryParse(text);
        },
      );
      final releaseDate = element
          .querySelector('.chapter-release-date')
          ?.text
          .trim()
          .asDateTime
          ?.toIso8601String();
      final chapter = text?.nonNulls.firstOrNull;

      data.add(
        Chapter(
          title: title?.trim(),
          chapter: chapter != null ? '$chapter' : null,
          readableAt: releaseDate?.asDateTime,
          webUrl: url,
        ),
      );
    }
    return data;
  }
}
