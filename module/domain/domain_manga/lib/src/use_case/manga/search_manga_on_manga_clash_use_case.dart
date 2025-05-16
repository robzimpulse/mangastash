import 'dart:async';
import 'dart:math';

import 'package:core_environment/core_environment.dart'
    show toBeginningOfSentenceCase;
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';

class SearchMangaOnMangaClashUseCaseUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final SyncMangasDao _syncMangasDao;
  final LogBox _logBox;

  SearchMangaOnMangaClashUseCaseUseCase({
    required HeadlessWebviewManager webview,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required SyncMangasDao syncMangasDao,
    required LogBox logBox,
  })  : _webview = webview,
        _mangaServiceFirebase = mangaServiceFirebase,
        _syncMangasDao = syncMangasDao,
        _logBox = logBox,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    final page = max(1, parameter.page ?? 0);
    final url = [
      [
        'https://toonclash.com',
        'page',
        '$page',
      ].join('/'),
      {
        's': parameter.title ?? '',
        'post_type': 'wp-manga',
        if (parameter.orders?.containsKey(SearchOrders.rating) == true)
          'm_orderby': 'rating',
        if (parameter.orders?.containsKey(SearchOrders.updatedAt) == true)
          'm_orderby': 'latest',
      }.entries.map((e) => '${e.key}=${e.value}').join('&'),
    ].join('?');

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final List<Manga> mangas = [];
    for (final element in document.querySelectorAll('.c-tabs-item__content')) {
      final title = element.querySelector('div.post-title')?.text.trim();
      final webUrl = element
          .querySelector('div.post-title')
          ?.querySelector('a')
          ?.attributes['href']
          ?.trim();
      final coverUrl = element
          .querySelector('.tab-thumb')
          ?.querySelector('img')
          ?.attributes['data-src']
          ?.trim();
      final genres = element
          .querySelector('div.post-content_item.mg_genres')
          ?.querySelector('div.summary-content')
          ?.text
          .split(',')
          .map((e) => toBeginningOfSentenceCase(e.trim()));
      final status = element
          .querySelector('div.post-content_item.mg_status')
          ?.querySelector('div.summary-content')
          ?.text
          .trim();

      mangas.add(
        Manga(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          source: MangaSourceEnum.mangaclash,
          status: toBeginningOfSentenceCase(status),
          tags: genres?.map((e) => MangaTag(name: e)).toList(),
        ),
      );
    }

    final total = document
        .querySelector('.wp-pagenavi')
        ?.querySelector('.pages')
        ?.text
        .split(' ')
        .map((e) => int.tryParse(e))
        .nonNulls
        .last;

    final data = await sync(
      logBox: _logBox,
      syncMangasDao: _syncMangasDao,
      mangaTagServiceFirebase: _mangaTagServiceFirebase,
      mangaServiceFirebase: _mangaServiceFirebase,
      values: mangas,
    );

    return Success(
      Pagination(
        data: data,
        page: page,
        limit: data.length,
        total: total ?? data.length,
        sourceUrl: url,
      ),
    );
  }
}
