import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../manager/headless_webview_manager.dart';

class GetMangaOnMangaClashUseCase {
  final MangaServiceFirebase _mangaServiceFirebase;
  final HeadlessWebviewManager _webview;

  GetMangaOnMangaClashUseCase({
    required MangaServiceFirebase mangaServiceFirebase,
    required HeadlessWebviewManager webview,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
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
      result.description == description
          ? result
          : await _mangaServiceFirebase.update(
              key: mangaId,
              update: (old) async => old.copyWith(description: description),
              ifAbsent: () async => result.copyWith(description: description),
            ),
    );
  }
}
