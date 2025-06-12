import 'dart:math';

import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../exception/failed_parsing_html_exception.dart';
import '../../extension/search_url_mixin.dart';
import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_list_html_parser.dart';
import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase with SyncMangasMixin {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _mangaDao = mangaDao,
        _webview = webview,
        _logBox = logBox;

  Future<Result<Pagination<Manga>>> execute({
    required String? source,
    required SearchMangaParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    if (source == Source.mangadex().name) {
      return _searchMangaOnMangaDexUseCase.execute(parameter: parameter);
    }

    final page = max(1, parameter.page ?? 0);

    String url = '';
    if (source == Source.asurascan().name) {
      url = parameter.asurascan;
    } else if (source == Source.mangaclash().name) {
      url = parameter.mangaclash;
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(FailedParsingHtmlException(url));
    }

    final parser = MangaListHtmlParser.forSource(
      root: document,
      source: source,
    );

    final data = await sync(
      dao: _mangaDao,
      values: [...parser.mangas.map((e) => e.copyWith(source: source))],
      logBox: _logBox,
    );

    return Success(
      Pagination(
        data: data,
        page: page,
        limit: parser.mangas.length,
        total: parser.mangas.length,
        hasNextPage: parser.haveNextPage,
        sourceUrl: url,
        // TODO: add metadata (all available tags / order / filter)
      ),
    );
  }
}
