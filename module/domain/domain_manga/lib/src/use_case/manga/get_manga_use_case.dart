import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/base/manga_detail_html_parser.dart';

class GetMangaUseCase with SyncMangasMixin {
  final MangaService _mangaService;
  final HeadlessWebviewManager _webview;
  final MangaDao _mangaDao;
  final LogBox _logBox;

  GetMangaUseCase({
    required HeadlessWebviewManager webview,
    required MangaService mangaService,
    required MangaDao mangaDao,
    required LogBox logBox,
  })  : _mangaService = mangaService,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Manga> _mangadex({
    required String source,
    required String mangaId,
  }) async {
    final result = await _mangaService.detail(
      id: mangaId,
      includes: [Include.author.rawValue, Include.coverArt.rawValue],
    );

    final manga = result.data;

    if (manga == null) {
      throw Exception('Manga not found');
    }

    return Manga.from(data: manga).copyWith(source: source);
  }

  Future<Manga> _scrapping({
    required String source,
    required Manga? manga,
  }) async {
    final url = manga?.webUrl;

    if (manga == null || url == null) {
      throw Exception('Data not found');
    }

    final isValid = [
      manga.author != null,
      manga.description != null,
      manga.tags?.isNotEmpty == true,
    ].every((e) => e);

    if (isValid) {
      return manga;
    }

    final document = await _webview.open(url);

    if (document == null) {
      throw Exception('Error parsing html');
    }

    final parser = MangaDetailHtmlParser.forSource(
      root: document,
      source: source,
    );

    return parser.manga.copyWith(source: source, webUrl: url);
  }

  Future<Result<Manga>> execute({
    required String source,
    required String mangaId,
  }) async {
    try {
      final raw = await _mangaDao.search(ids: [mangaId]);
      final manga = Manga.fromDatabase(raw.firstOrNull);

      // TODO: add caching since parsing from html require a lot of resource
      final promise = source == Source.mangadex().name
          ? _mangadex(source: source, mangaId: mangaId)
          : _scrapping(manga: manga, source: source);

      final results = await sync(
        dao: _mangaDao,
        values: [await promise],
        logBox: _logBox,
      );

      final result = results.firstOrNull;

      if (result == null) {
        throw Exception('Data not found');
      }

      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
