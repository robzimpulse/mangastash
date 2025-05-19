import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

class MangaClashChapterListHtmlParser {
  final Document root;

  MangaClashChapterListHtmlParser({required this.root});

  List<MangaChapter> get chapters {
    final List<MangaChapter> data = [];

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
        MangaChapter(
          title: title?.trim(),
          chapter: chapter != null ? '$chapter' : null,
          readableAt: releaseDate,
          webUrl: url,
        ),
      );
    }
    return data;
  }
}
