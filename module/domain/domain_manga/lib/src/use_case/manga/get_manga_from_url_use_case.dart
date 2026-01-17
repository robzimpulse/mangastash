import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../../extension/data_scrapped_extension.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaFromUrlUseCase with SyncMangasMixin {
  final HeadlessWebviewUseCase _webview;
  final ConverterCacheManager _converterCacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaFromUrlUseCase({
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaDao = mangaDao,
       _converterCacheManager = converterCacheManager,
       _logBox = logBox,
       _webview = webview;

  Future<Manga> _scrapping({
    required SourceEnum source,
    required String url,
    bool useCache = true,
  }) async {
    final selector = [
      'button',
      'inline-flex',
      'items-center',
      'whitespace-nowrap',
      'px-4',
      'py-2',
      'w-full',
      'justify-center',
      'font-normal',
      'align-middle',
      'border-solid',
    ].join('.');

    final document = await _webview.open(
      url,
      scripts: [
        if (source == SourceEnum.asurascan)
          'window.document.querySelectorAll(\'$selector\')[0].click()',
      ],
      useCache: useCache,
    );

    final parser = MangaDetailHtmlParser.forSource(
      root: HtmlDocument()..nodes.addAll(document.nodes),
      source: source,
    );

    final manga = await parser.manga.then(
      (e) => e.convert(manager: _converterCacheManager),
    );

    return manga.copyWith(
      source: source.name,
      webUrl: url,
      tags: manga.tags?.map((e) => e.copyWith(source: source.name)).toList(),
    );
  }

  Future<Result<Manga>> execute({
    required SourceEnum source,
    required String url,
    bool useCache = true,
  }) async {
    try {
      final raw = await _mangaDao.search(webUrls: [url]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      if (manga != null && manga.propertiesFilled && useCache) {
        return Success(manga);
      }

      final results = await sync(
        dao: _mangaDao,
        values: [
          await _scrapping(source: source, url: (manga?.webUrl).or(url)),
        ],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw DataNotFoundException();
      }

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
