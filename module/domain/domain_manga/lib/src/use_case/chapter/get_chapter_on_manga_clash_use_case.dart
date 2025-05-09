import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_chapter_mixin.dart';

class GetChapterOnMangaClashUseCase with SyncChapterMixin {
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final HeadlessWebviewManager _webview;

  GetChapterOnMangaClashUseCase({
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required HeadlessWebviewManager webview,
  })  : _mangaChapterServiceFirebase = mangaChapterServiceFirebase,
        _webview = webview;

  Future<Result<MangaChapter>> execute({
    required String chapterId,
    required String mangaId,
  }) async {
    final raw = await _mangaChapterServiceFirebase.get(id: chapterId);
    final result = raw.let((e) => MangaChapter.fromFirebaseService(e));
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    if (result.images?.isNotEmpty == true) return Success(result);

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final List<(int, String)> data = [];
    final element = document.querySelector('.reading-content');
    for (final image in element?.querySelectorAll('img') ?? <Element>[]) {
      final id = image.attributes['id']?.split('-').lastOrNull;
      if (id == null) continue;
      final url = image.attributes['data-src'];
      final index = int.tryParse(id);
      if (index == null || url == null) continue;
      data.add((index, url.trim()));
    }

    final tmp = List.of(data)..sort((a, b) => a.$1.compareTo(b.$1));
    final images = List.of(tmp.map((e) => e.$2));

    return Success(
      await sync(
        mangaChapterServiceFirebase: _mangaChapterServiceFirebase,
        value: result.copyWith(images: images),
      ),
    );
  }
}
