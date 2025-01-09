import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart'
    show toBeginningOfSentenceCase;
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../manager/headless_webview_manager.dart';

class SearchMangaOnMangaClashUseCaseUseCase {
  final LogBox _log;
  final HeadlessWebviewManager _webview;
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;

  SearchMangaOnMangaClashUseCaseUseCase({
    required LogBox log,
    required HeadlessWebviewManager webview,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
  })  : _log = log,
        _webview = webview,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    _log.log(
      '${parameter.toJson()}',
      name: runtimeType.toString(),
    );
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
          .map((e) => toBeginningOfSentenceCase(e.trim().toLowerCase()));
      final status = element
          .querySelector('div.post-content_item.mg_status')
          ?.querySelector('div.summary-content')
          ?.text
          .trim()
          .toLowerCase();

      mangas.add(
        Manga(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          source: MangaSourceEnum.mangaclash,
          status: status,
          tags: genres?.map((e) => MangaTag(name: e)).toList(),
        ),
      );
    }

    final mangaTags = mangas.expand((e) => e.tagsName).toSet();
    final cachedTags = await _mangaTagServiceFirebase.search(
      tags: mangaTags.map((e) => MangaTag(name: e)).toList(),
    );
    final List<MangaTag> tags = [];

    for (final tag in mangaTags) {
      final cached = cachedTags.firstWhereOrNull((e) => e.name == tag);
      tags.add(
        cached ?? await _mangaTagServiceFirebase.add(MangaTag(name: tag)),
      );
    }

    final cachedManga = await _mangaServiceFirebase.search(mangas: mangas);

    final List<Manga> data = [];
    for (final manga in mangas) {
      final mangaTags = tags.where((tag) => manga.tagsName.contains(tag.name));
      final cached = cachedManga.firstWhereOrNull(
        (cache) => cache.webUrl == manga.webUrl,
      );
      data.add(
        cached ??
            await _mangaServiceFirebase.add(
              manga.copyWith(tags: mangaTags.toList()),
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
        data: data,
        page: '$page',
        limit: data.length,
        total: total ?? data.length,
      ),
    );
  }
}
