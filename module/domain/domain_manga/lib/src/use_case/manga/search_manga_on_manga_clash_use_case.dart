import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
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
          .map((e) => e.trim());
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
          tags: genres?.map((e) => MangaTag(name: e)).toList(),
          status: status,
        ),
      );
    }

    final slicesUrls = mangas.map((e) => e.webUrl).whereNotNull().slices(10);
    final promisesUrls = slicesUrls.map(
      (urls) => _mangaServiceFirebase.search(
        webUrl: urls.whereNotNull().toList(),
        limit: 100,
      ),
    );
    final results1 = await Future.wait(promisesUrls);
    final cachedMangas = results1.expand((result) => result.data ?? <Manga>[]);

    final slicesTags =
        mangas.expand((e) => e.tagsName).whereNotNull().slices(10);
    final promisesTags = slicesTags.map(
      (tags) => _mangaTagServiceFirebase.search(
        name: tags,
      ),
    );
    final results2 = await Future.wait(promisesTags);
    final cachedTags = results2.expand((result) => result.data ?? <MangaTag>[]);

    final List<Manga> result = [];

    for (final manga in mangas) {
      final List<MangaTag> tags = [];
      for (final tag in manga.tags ?? <MangaTag>[]) {
        final cache = cachedTags.firstWhereOrNull(
          (cache) => cache.name == tag.name,
        );
        tags.add(
          cache == null
              ? await _mangaTagServiceFirebase.add(tag)
              : await _mangaTagServiceFirebase.update(
                  cache.copyWith(name: tag.name),
                ),
        );
      }

      final cacheManga = cachedMangas.firstWhereOrNull(
        (cache) => cache.webUrl == manga.webUrl,
      );

      result.add(
        cacheManga == null
            ? await _mangaServiceFirebase.add(
                manga.copyWith(tags: tags),
              )
            : await _mangaServiceFirebase.update(
                manga.copyWith(id: cacheManga.id, tags: tags),
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
        data: result,
        page: '$page',
        limit: result.length,
        total: total ?? 0,
      ),
    );
  }
}
