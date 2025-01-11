import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../../manager/headless_webview_manager.dart';

class GetChapterOnMangaClashUseCase {
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
    final result = await _mangaChapterServiceFirebase.get(id: chapterId);
    final url = result?.webUrl;
    final imageUrls = result?.images;

    if (result != null && imageUrls?.isNotEmpty == true) {
      return Success(result);
    }

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

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
      await _mangaChapterServiceFirebase.update(
        key: chapterId,
        update: (old) async => old.copyWith(images: images),
        ifAbsent: () async => result.copyWith(images: images),
      ),
    );
  }
}
