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

    final document = await _webview.open(
      'https://toonclash.com/?s=${parameter.title ?? ''}&post_type=wp-manga',
    );

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }
    final pagination = document.querySelector('.wp-pagenavi');
    final total = pagination?.querySelector('.pages')?.text;
    final page = total?.split(' ').map((e) => int.tryParse(e)).whereNotNull();
    final data = document.querySelectorAll('.c-tabs-item__content');

    return Success(
      Pagination<Manga>(
        data: data.map(
          (e) {
            final thumbnail = e.querySelector('.tab-thumb');
            final title = thumbnail?.querySelector('a')?.attributes['title'];
            final coverUrl = thumbnail?.querySelector('img')?.attributes['data-src'];
            return Manga(
              title: title,
              coverUrl: coverUrl,
            );
          },
        ).toList(),
        offset: '${page?.first ?? 1}',
        limit: data.length,
        total: page?.last ?? 0,
      ),
    );
  }
}
