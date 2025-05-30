import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';
import 'get_manga_on_mangadex_use_case.dart';

class GetMangaUseCase with SyncMangasMixin {
  final GetMangaOnMangaDexUseCase _getMangaOnMangaDexUseCase;
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaUseCase({
    required GetMangaOnMangaDexUseCase getMangaOnMangaDexUseCase,
    required HeadlessWebviewManager webview,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _getMangaOnMangaDexUseCase = getMangaOnMangaDexUseCase,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Manga>> execute({
    required MangaSourceEnum? source,
    required String mangaId,
  }) async {
    if (source == null) {
      return Error(Exception('Empty Source'));
    }

    final raw = await _mangaDao.getManga(mangaId);

    final result = raw?.let((raw) => Manga.fromDrift(raw.$1, tags: raw.$2));

    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final isValid = [
      result.author != null,
      result.description != null,
      result.tags?.isNotEmpty == true,
    ].every((e) => e);

    if (isValid) {
      return Success(result);
    }

    if (source == MangaSourceEnum.mangadex) {
      return _getMangaOnMangaDexUseCase.execute(mangaId: mangaId);
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final parser = MangaDetailHtmlParser.forSource(
      root: document,
      source: source,
    );

    final results = await sync(
      logBox: _logBox,
      mangaDao: _mangaDao,
      values: [parser.manga.merge(result).copyWith(source: source)],
    );

    final data = results.firstOrNull;

    if (data == null) {
      return Error(Exception('Error syncing manga'));
    }

    return Success(data);
  }
}
