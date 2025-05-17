import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';

class GetMangaOnMangaClashUseCase with SyncMangasMixin {
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaDao _mangaDao;
  final HeadlessWebviewManager _webview;
  final LogBox _logBox;

  GetMangaOnMangaClashUseCase({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaDao mangaDao,
    required HeadlessWebviewManager webview,
    required LogBox logBox,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase,
        _mangaDao = mangaDao,
        _logBox = logBox,
        _webview = webview;

  Future<Result<Manga>> execute({required String mangaId}) async {
    final result = await _mangaServiceFirebase.get(id: mangaId);
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    if (result.description != null) {
      return Success(Manga.fromFirebaseService(result));
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final description = document
        .querySelector('div.description-summary')
        ?.querySelectorAll('p')
        .map((e) => e.text.trim())
        .join('\n\n');

    final process = sync(
      logBox: _logBox,
      mangaDao: _mangaDao,
      mangaTagServiceFirebase: _mangaTagServiceFirebase,
      mangaServiceFirebase: _mangaServiceFirebase,
      values: [
        Manga.fromFirebaseService(
          result.copyWith(
            description: description,
            source: MangaSourceEnum.mangaclash.value,
          ),
        ),
      ],
    );

    final data = (await process).firstOrNull;

    if (data == null) {
      return Error(Exception('Error syncing manga'));
    }

    return Success(data);
  }
}
