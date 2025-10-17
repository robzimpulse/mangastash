import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/src/manga.dart';

import 'base/manga_list_html_parser.dart';

class AsuraScanMangaListHtmlParser extends MangaListHtmlParser {
  @override
  Future<List<Manga>> get mangas async {
    final queries = ['div', 'grid', 'grid-cols-2', 'gap-3', 'p-4'].join('.');
    final region = root.querySelector(queries)?.querySelectorAll('a');
    return (region ?? []).map((e) {
      final webUrl = ['https://asuracomic.net', e.attributes['href']].join('/');
      final status = e.querySelector('span.status.bg-blue-700')?.text.trim();
      final coverUrl = e.querySelector('img.rounded-md')?.attributes['src'];
      final title = e.querySelector('span.block.font-bold')?.text.trim();
      return Manga(
        title: title,
        coverUrl: coverUrl,
        webUrl: webUrl,
        status: toBeginningOfSentenceCase(status?.toLowerCase()),
      );
    }).toList();
  }

  @override
  Future<bool?> get haveNextPage async {
    final queries = [
      'a',
      'flex',
      'items-center',
      'bg-themecolor',
      'text-white',
      'px-8',
      'text-center',
      'cursor-pointer',
    ].join('.');

    final region = root.querySelector(queries);

    return region?.attributes['style'] == 'pointer-events:auto';
  }

  AsuraScanMangaListHtmlParser({
    required super.root,
    required super.converterCacheManager,
  });
}
