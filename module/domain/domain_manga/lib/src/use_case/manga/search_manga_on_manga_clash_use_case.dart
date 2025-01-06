import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../manager/headless_webview_manager.dart';

class SearchMangaOnMangaClashUseCaseUseCase {
  final LogBox _log;
  final HeadlessWebviewManager _webview;

  SearchMangaOnMangaClashUseCaseUseCase({
    required LogBox log,
    required HeadlessWebviewManager webview,
  })  : _log = log,
        _webview = webview;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    _log.log(
      '${parameter.toJson()}',
      name: runtimeType.toString(),
    );
    final url = [
      [
        'https://toonclash.com',
        'page',
        parameter.page ?? '0',
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
    final pagination = document.querySelector('.wp-pagenavi');
    final total = pagination?.querySelector('.pages')?.text;
    final page = total?.split(' ').map((e) => int.tryParse(e)).whereNotNull();
    final data = document.querySelectorAll('.c-tabs-item__content');

    final List<Manga> mangas = [];

    for (final element in data) {
      final title = element.querySelector('div.post-title')?.text.trim();
      final webUrl = element
          .querySelector('div.post-title')
          ?.querySelector('a')
          ?.attributes['href'];
      final coverUrl = element
          .querySelector('.tab-thumb')
          ?.querySelector('img')
          ?.attributes['data-src'];

      mangas.add(
        Manga(
          title: title,
          coverUrl: coverUrl,
          webUrl: webUrl,
          source: MangaSourceEnum.mangaclash,
          // this.author,
          // this.status,
          // this.description,
          // this.tags,
        ),
      );
    }

    return Success(
      Pagination<Manga>(
        data: mangas,
        offset: '${page?.first ?? 1}',
        limit: data.length,
        total: page?.last ?? 0,
      ),
    );
  }
}
