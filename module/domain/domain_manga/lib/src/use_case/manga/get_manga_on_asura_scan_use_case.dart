import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';
import '../../parser/asura_scan_manga_detail_html_parser.dart';

class GetMangaOnAsuraScanUseCase with SyncMangasMixin {
  final MangaDao _mangaDao;
  final HeadlessWebviewManager _webview;
  final LogBox _logBox;

  GetMangaOnAsuraScanUseCase({
    required MangaDao mangaDao,
    required HeadlessWebviewManager webview,
    required LogBox logBox,
  })  : _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Manga>> execute({required String mangaId}) async {
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

    if (isValid) return Success(result);

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final manga = AsuraScanMangaDetailHtmlParser(root: document);

    final process = sync(
      logBox: _logBox,
      mangaDao: _mangaDao,
      values: [
        manga.manga.merge(result).copyWith(source: MangaSourceEnum.asurascan),
      ],
    );

    final data = (await process).firstOrNull;

    if (data == null) {
      return Error(Exception('Error Syncing Manga'));
    }

    return Success(data);
  }
}
