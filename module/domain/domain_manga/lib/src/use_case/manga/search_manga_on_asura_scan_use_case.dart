import 'dart:math';

import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/asura_scan_manga_list_html_parser.dart';

class SearchMangaOnAsuraScanUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  SearchMangaOnAsuraScanUseCase({
    required HeadlessWebviewManager webview,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _webview = webview,
        _mangaDao = mangaDao,
        _logBox = logBox;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    final page = max(1, parameter.page ?? 0);
    final url = [
      [
        'https://asuracomic.net',
        'series',
      ].join('/'),
      {
        'name': parameter.title ?? '',
        'page': page,
        if (parameter.orders?.containsKey(SearchOrders.rating) == true)
          'order': 'rating',
        if (parameter.orders?.containsKey(SearchOrders.updatedAt) == true)
          'order': 'update',
      }.entries.map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final mangas = AsuraScanMangaListHtmlParser(root: document);

    final data = await sync(
      logBox: _logBox,
      mangaDao: _mangaDao,
      values: mangas.mangas,
    );

    return Success(
      Pagination(
        data: data,
        page: page,
        limit: data.length,
        total: data.length,
        hasNextPage: mangas.haveNextPage,
        sourceUrl: url,
      ),
    );
  }
}
