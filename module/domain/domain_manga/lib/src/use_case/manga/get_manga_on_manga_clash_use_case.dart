import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_manga_mixin.dart';

class GetMangaOnMangaClashUseCase with SyncMangaMixin {
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final HeadlessWebviewManager _webview;

  GetMangaOnMangaClashUseCase({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required HeadlessWebviewManager webview,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase,
        _webview = webview;

  Future<Result<Manga>> execute({required String mangaId}) async {
    final result = await _mangaServiceFirebase.get(id: mangaId);
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
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

    return Success(
      await sync(
        mangaTagServiceFirebase: _mangaTagServiceFirebase,
        mangaServiceFirebase: _mangaServiceFirebase,
        manga: result.copyWith(description: description),
      ),
    );
  }
}
