import 'dart:math';

import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../extension/search_url_mixin.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_list_html_parser.dart';
import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _mangaDao = mangaDao,
        _webview = webview,
        _logBox = logBox;

  Future<Result<Pagination<Manga>>> execute({
    required MangaSourceEnum? source,
    required SearchMangaParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    if (source == MangaSourceEnum.mangadex) {
      return _searchMangaOnMangaDexUseCase.execute(parameter: parameter);
    }

    final page = max(1, parameter.page ?? 0);

    final url = switch (source) {
      MangaSourceEnum.mangadex => '',
      MangaSourceEnum.asurascan => parameter.asurascan,
      MangaSourceEnum.mangaclash => parameter.mangaclash,
    };

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final parser = MangaListHtmlParser.forSource(
      root: document,
      source: source,
    );

    final data = await sync(
      mangaDao: _mangaDao,
      values: parser.mangas,
      logBox: _logBox,
    );

    return Success(
      Pagination(
        data: data.map((e) => e.copyWith(source: source)).toList(),
        page: page,
        limit: parser.mangas.length,
        total: parser.total,
        hasNextPage: parser.haveNextPage,
        sourceUrl: url,
      ),
    );
  }
}
