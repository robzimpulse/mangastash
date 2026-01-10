import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';

import 'base/manga_detail_html_parser.dart';

class AsuraScanMangaDetailHtmlParser extends MangaDetailHtmlParser {
  AsuraScanMangaDetailHtmlParser({required super.root});

  @override
  Future<Manga> get manga async {
    final query = ['div', 'float-left', 'relative', 'z-0'].join('.');
    final region = root.querySelector(query);

    final title = region?.querySelector('span.text-xl.font-bold')?.text.trim();

    final description =
        region?.querySelector('span.font-medium.text-sm')?.text.trim();

    final mQuery = ['div.grid', 'grid-cols-1', 'gap-5', 'mt-8'].join('.');
    final metas = region?.querySelector(mQuery)?.children.map((e) {
      final first = e.querySelector('h3.font-medium.text-sm');
      return MapEntry(
        first?.text.trim(),
        first?.nextElementSibling?.text.trim(),
      );
    });
    final metadata = Map.fromEntries(metas ?? <MapEntry<String?, String>>[]);
    final author = metadata['Author'];
    final genres = region
        ?.querySelector('div.space-y-1.pt-4')
        ?.querySelector('div.flex.flex-row.flex-wrap.gap-3')
        ?.children
        .map((e) => e.text.trim());

    final coverUrl =
        region
            ?.querySelector('div.relative.col-span-full.space-y-3.px-6')
            ?.querySelector('img')
            ?.attributes['src'];

    return Manga(
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      tags: [
        ...?genres?.map(
          (e) => Tag(name: e, source: SourceEnum.mangaclash.label),
        ),
      ],
    );
  }
}
