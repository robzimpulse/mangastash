import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart'
    show toBeginningOfSentenceCase;
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';

class SearchMangaOnMangaClashUseCaseUseCase {
  final HeadlessWebviewManager _webview;

  SearchMangaOnMangaClashUseCaseUseCase({
    required HeadlessWebviewManager webview,
  }) : _webview = webview;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    final page = max(1, int.tryParse(parameter.page ?? '0') ?? 0);
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
      return Error(Exception('Error parsing html'));
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
        .whereNotNull()
        .last;

    return Success(
      Pagination<Manga>(
        data: mangas,
        page: '$page',
        limit: mangas.length,
        total: total ?? mangas.length,
      ),
    );
  }
}
