import 'dart:math';

import 'package:core_environment/core_environment.dart'
    show toBeginningOfSentenceCase;
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';

class SearchMangaOnAsuraScanUseCase with SyncMangasMixin {
  final HeadlessWebviewManager _webview;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;

  SearchMangaOnAsuraScanUseCase({
    required HeadlessWebviewManager webview,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
  })  : _webview = webview,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

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

    final contentMangas = document
        .querySelector(
          [
            'div',
            'grid',
            'grid-cols-2',
            'gap-3',
            'p-4',
          ].join('.'),
        )
        ?.querySelectorAll('a');

    final List<Manga> mangas = [];
    for (final element in contentMangas ?? <Element>[]) {
      final webUrl = [
        'https://asuracomic.net',
        element.attributes['href'],
      ].join('/');
      final status =
          element.querySelector('span.status.bg-blue-700')?.text.trim();
      final coverUrl =
          element.querySelector('img.rounded-md')?.attributes['src'];
      final title = element.querySelector('span.block.font-bold')?.text.trim();
      mangas.add(
        Manga(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          source: MangaSourceEnum.asurascan,
          status: toBeginningOfSentenceCase(status),
        ),
      );
    }

    final contentPagination = document.querySelector(
      [
        'a',
        'flex',
        'items-center',
        'bg-themecolor',
        'text-white',
        'px-8',
        'text-center',
        'cursor-pointer',
      ].join('.'),
    );
    final haveNextPage =
        contentPagination?.attributes['style'] == 'pointer-events:auto';

    final data = await sync(
      mangaTagServiceFirebase: _mangaTagServiceFirebase,
      mangaServiceFirebase: _mangaServiceFirebase,
      mangas: mangas,
    );

    return Success(
      Pagination(
        data: data,
        page: page,
        limit: data.length,
        total: data.length,
        hasNextPage: haveNextPage,
        sourceUrl: url,
      ),
    );
  }
}
