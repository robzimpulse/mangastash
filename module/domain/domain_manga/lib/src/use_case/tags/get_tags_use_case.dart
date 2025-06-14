import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_tags_mixin.dart';
import 'get_tags_on_mangadex_use_case.dart';

class GetTagsUseCase with SyncTagsMixin {
  final GetTagsOnMangaDexUseCase _getTagsOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final TagDao _tagDao;
  final LogBox _logBox;

  const GetTagsUseCase({
    required GetTagsOnMangaDexUseCase getTagsOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required TagDao tagDao,
    required LogBox logBox,
  })  : _getTagsOnMangaDexUseCase = getTagsOnMangaDexUseCase,
        _tagDao = tagDao,
        _webview = webview,
        _logBox = logBox;

  Future<Result<List<Tag>>> execute({required String source}) async {
    if (source == Source.mangadex().name) {
      return _getTagsOnMangaDexUseCase.execute();
    }

    // TODO: implement get tags other than mangadex
    return Success([]);

    // final page = max(1, parameter.page ?? 0);
    //
    // String url = '';
    // if (source == Source.asurascan().name) {
    //   url = parameter.asurascan;
    // } else if (source == Source.mangaclash().name) {
    //   url = parameter.mangaclash;
    // }
    //
    // final document = await _webview.open(url);
    //
    // if (document == null) {
    //   return Error(FailedParsingHtmlException(url));
    // }
    //
    // final parser = MangaListHtmlParser.forSource(
    //   root: document,
    //   source: source,
    // );
    //
    // final data = await sync(
    //   dao: _mangaDao,
    //   values: [...parser.mangas.map((e) => e.copyWith(source: source))],
    //   logBox: _logBox,
    // );
    //
    // return Success(
    //   Pagination(
    //     data: data,
    //     page: page,
    //     limit: parser.mangas.length,
    //     total: parser.mangas.length,
    //     hasNextPage: parser.haveNextPage,
    //     sourceUrl: url,
    //     // TODO: add metadata (all available tags / order / filter)
    //   ),
    // );
  }
}