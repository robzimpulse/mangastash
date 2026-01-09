import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';

import 'base/manga_list_html_parser.dart';

class MangaClashMangaListHtmlParser extends MangaListHtmlParser {
  @override
  Future<List<Manga>> get mangas async {
    final List<Manga> mangas = [];
    for (final element in root.querySelectorAll('.c-tabs-item__content')) {
      final title = element.querySelector('div.post-title')?.text.trim();
      final webUrl =
          element
              .querySelector('div.post-title')
              ?.querySelector('a')
              ?.attributes['href']
              ?.trim();
      final coverUrl =
          element
              .querySelector('.tab-thumb')
              ?.querySelector('img')
              ?.attributes['data-src']
              ?.trim();
      final genres = element
          .querySelector('div.post-content_item.mg_genres')
          ?.querySelector('div.summary-content')
          ?.text
          .split(',')
          // TODO: move to intermediary object like [ChapterScrapped]
          .map((e) => toBeginningOfSentenceCase(e.trim()));
      final status =
          element
              .querySelector('div.post-content_item.mg_status')
              ?.querySelector('div.summary-content')
              ?.text
              .trim();

      mangas.add(
        Manga(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          // TODO: move to intermediary object like [ChapterScrapped]
          status: toBeginningOfSentenceCase(status?.toLowerCase()),
          tags:
              genres
                  ?.map(
                    (e) =>
                    // TODO: move to intermediary object like [ChapterScrapped]
                    Tag(name: toBeginningOfSentenceCase(e.toLowerCase())),
                  )
                  .toList(),
        ),
      );
    }
    return mangas;
  }

  @override
  Future<bool?> get haveNextPage async {
    final values =
        root
            .querySelector('.wp-pagenavi')
            ?.querySelector('.pages')
            ?.text
            .split(' ')
            .map((e) => int.tryParse(e))
            .nonNulls;

    return values?.firstOrNull != values?.lastOrNull;
  }

  MangaClashMangaListHtmlParser({required super.root});
}
