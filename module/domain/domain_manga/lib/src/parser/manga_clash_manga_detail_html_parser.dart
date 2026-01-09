import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';

import 'base/manga_detail_html_parser.dart';

class MangaClashMangaDetailHtmlParser extends MangaDetailHtmlParser {
  MangaClashMangaDetailHtmlParser({required super.root});

  @override
  Future<Manga> get manga async {
    final description = root
        .querySelector('div.description-summary')
        ?.querySelectorAll('p')
        .map((e) => e.text.trim())
        .join('\n\n');

    final title = root.querySelector('div.post-title')?.text.trim();

    final authors = root.querySelector('div.author-content')?.text.trim();

    final coverUrl =
        root
            .querySelector('div.summary_image')
            ?.querySelector('img')
            ?.attributes['src'];

    final tags = root
        .querySelector('div.genres-content')
        ?.text
        .trim()
        .split(',');

    return Manga(
      title: title,
      author: authors,
      coverUrl: coverUrl,
      description: description,
      tags: [
        ...?tags?.map(
          (e) => Tag(
            // TODO: move to intermediary object like [ChapterScrapped]
            name: toBeginningOfSentenceCase(e.trim()),
            source: SourceEnum.mangaclash.name,
          ),
        ),
      ],
    );
  }
}
