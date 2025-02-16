import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart'
    show toBeginningOfSentenceCase;
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';

class SearchMangaOnMangaClashUseCaseUseCase {
  final HeadlessWebviewManager _webview;
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;

  SearchMangaOnMangaClashUseCaseUseCase({
    required LogBox log,
    required HeadlessWebviewManager webview,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
  })  : _webview = webview,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

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

    final tags = await _mangaTagServiceFirebase.sync(
      values: List.of(
        Set.of(mangas.expand((e) => e.tagsName).map((e) => MangaTag(name: e))),
      ),
    );

    final data = await _mangaServiceFirebase.sync(
      values: List.of(
        mangas.map(
          (manga) => manga.copyWith(
            tags: List.of(
              tags.where((tag) => manga.tagsName.contains(tag.name)),
            ),
          ),
        ),
      ),
    );

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
        data: data,
        page: '$page',
        limit: data.length,
        total: total ?? data.length,
      ),
    );
  }
}
