import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../extension/search_url_extension.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_list_html_parser.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final MangaRepository _mangaRepository;
  final HeadlessWebviewManager _webview;
  final StorageManager _storageManager;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required MangaRepository mangaRepository,
    required HeadlessWebviewManager webview,
    required StorageManager storageManager,
    required MangaDao mangaDao,
    required LogBox logBox,
  }) : _mangaRepository = mangaRepository,
       _storageManager = storageManager,
       _mangaDao = mangaDao,
       _webview = webview,
       _logBox = logBox;

  Future<Pagination<Manga>> _mangadex({
    required SourceEnum source,
    required SearchMangaParameter parameter,
  }) async {
    final result = await _mangaRepository.search(
      parameter: parameter.copyWith(
        includes: [...?parameter.includes, Include.author, Include.coverArt],
      ),
    );

    return Pagination(
      data: [
        ...?result.data?.map(
          (e) => Manga.from(data: e).copyWith(source: source.name),
        ),
      ],
      offset: result.offset?.toInt(),
      limit: result.limit?.toInt() ?? 0,
      total: result.total?.toInt() ?? 0,
    );
  }

  Future<Pagination<Manga>> _scrapping({
    required SourceEnum source,
    required SearchMangaParameter parameter,
  }) async {
    String url = '';
    if (source == SourceEnum.asurascan) {
      url = parameter.asurascan;
    } else if (source == SourceEnum.mangaclash) {
      url = parameter.mangaclash;
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw FailedParsingHtmlException(url);
    }

    final parser = MangaListHtmlParser.forSource(
      root: document,
      source: source,
      storageManager: _storageManager,
    );

    final mangas = await parser.mangas;

    return Pagination(
      data: [...mangas.map((e) => e.copyWith(source: source.name))],
      page: parameter.page,
      limit: mangas.length,
      total: mangas.length,
      hasNextPage: await parser.haveNextPage,
      sourceUrl: url,
    );
  }

  Future<Result<Pagination<Manga>>> execute({
    required SourceEnum source,
    required SearchMangaParameter parameter,
  }) async {
    try {
      final Pagination<Manga> data;
      if (source == SourceEnum.mangadex) {
        data = await _mangadex(source: source, parameter: parameter);
      } else {
        data = await _scrapping(source: source, parameter: parameter);
      }

      final result = data.copyWith(
        data: await sync(
          dao: _mangaDao,
          values: [...?data.data],
          logBox: _logBox,
        ),
      );

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
