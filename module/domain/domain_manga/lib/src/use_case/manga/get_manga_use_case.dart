import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaUseCase with SyncMangasMixin {
  final HeadlessWebviewUseCase _webview;
  final ConverterCacheManager _converterCacheManager;
  final MangaService _mangaService;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaUseCase({
    required HeadlessWebviewUseCase webview,
    required ConverterCacheManager converterCacheManager,
    required MangaService mangaService,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _converterCacheManager = converterCacheManager,
       _mangaService = mangaService,
       _mangaDao = mangaDao,
       _logBox = logBox,
       _webview = webview;

  Future<Manga> _mangadex({
    required SourceEnum source,
    required String mangaId,
  }) async {
    final result = await _mangaService.detail(
      id: mangaId,
      includes: [Include.author.rawValue, Include.coverArt.rawValue],
    );

    final manga = result.data;

    if (manga == null) {
      throw DataNotFoundException();
    }

    return Manga.from(data: manga).copyWith(source: source.name);
  }

  Future<Manga> _scrapping({
    required SourceEnum source,
    required String? url,
    bool useCache = true,
  }) async {
    if (url == null) {
      throw DataNotFoundException();
    }

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
      root: document,
      source: source,
      converterCacheManager: _converterCacheManager,
    );

    final manga = await parser.manga;

    return manga.copyWith(source: source.name, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required SourceEnum source,
    required String mangaId,
    bool useCache = true,
  }) async {
    try {
      final raw = await _mangaDao.search(ids: [mangaId]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      if (manga != null && manga.propertiesFilled) return Success(manga);

      final Manga data;
      if (source == SourceEnum.mangadex) {
        data = await _mangadex(source: source, mangaId: mangaId);
      } else {
        data = await _scrapping(
          url: manga?.webUrl,
          source: source,
          useCache: useCache,
        );
      }

      final results = await sync(
        dao: _mangaDao,
        values: [data],
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
