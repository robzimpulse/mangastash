import 'dart:async';

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

    // TODO: @robzimpulse implement asurascan search manga



    return Error(Exception('Unimplemented'));
  }
}
