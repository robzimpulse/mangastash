import 'dart:math';

import 'package:core_environment/core_environment.dart'
    show toBeginningOfSentenceCase;
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';

class SearchMangaOnAsuraScanUseCase {
  final HeadlessWebviewManager _webview;
  final MangaServiceFirebase _mangaServiceFirebase;

  SearchMangaOnAsuraScanUseCase({
    required HeadlessWebviewManager webview,
    required MangaServiceFirebase mangaServiceFirebase,
  })  : _webview = webview,
        _mangaServiceFirebase = mangaServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    final page = max(1, int.tryParse(parameter.page ?? '0') ?? 0);
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
      return Error(Exception('Error parsing html'));
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

    final data = await _mangaServiceFirebase.sync(values: mangas);

    return Success(
      Pagination<Manga>(
        data: data,
        page: '$page',
        limit: data.length,
        total: data.length,
        hasNextPage: haveNextPage,
      ),
    );
  }
}
