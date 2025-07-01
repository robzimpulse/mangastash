import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../extension/search_url_mixin.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_list_html_parser.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final HeadlessWebviewManager _webview;
  final BaseCacheManager _cacheManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required HeadlessWebviewManager webview,
    required BaseCacheManager cacheManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _mangaRepository = mangaRepository,
        _cacheManager = cacheManager,
        _mangaDao = mangaDao,
        _webview = webview,
        _logBox = logBox;

  Future<Pagination<Manga>> _mangadex({
    required String source,
    required SearchMangaParameter parameter,
  }) async {
    final result = await _mangaRepository.search(
      parameter: parameter.copyWith(
        includes: [
          ...?parameter.includes,
          Include.author,
          Include.coverArt,
        ],
      ),
    );

    return Pagination(
      data: [
        ...?result.data?.map(
          (e) => Manga.from(data: e).copyWith(source: source),
        ),
      ],
      offset: result.offset?.toInt(),
      limit: result.limit?.toInt() ?? 0,
      total: result.total?.toInt() ?? 0,
    );
  }

  Future<Pagination<Manga>> _scrapping({
    required String source,
    required SearchMangaParameter parameter,
  }) async {
    String url = '';
    if (source == Source.asurascan().name) {
      url = parameter.asurascan;
    } else if (source == Source.mangaclash().name) {
      url = parameter.mangaclash;
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = MangaListHtmlParser.forSource(
      root: document,
      source: source,
    );

    return Pagination(
      data: [...parser.mangas.map((e) => e.copyWith(source: source))],
      page: parameter.page,
      limit: parser.mangas.length,
      total: parser.mangas.length,
      hasNextPage: parser.haveNextPage,
      sourceUrl: url,
    );
  }

  Future<Result<Pagination<Manga>>> execute({
    required String source,
    required SearchMangaParameter parameter,
  }) async {
    try {
      // TODO: add caching since parsing from html require a lot of resource
      final promise = source == Source.mangadex().name
          ? _mangadex(source: source, parameter: parameter)
          : _scrapping(source: source, parameter: parameter);

      final data = await promise;

      return Success(
        data.copyWith(
          data: await sync(
            dao: _mangaDao,
            values: [...?data.data],
            logBox: _logBox,
          ),
        ),
      );

    } catch (e) {
      return Error(e);
    }
  }
}
