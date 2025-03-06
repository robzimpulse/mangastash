import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_manga_mixin.dart';

class GetMangaOnAsuraScanUseCase with SyncMangaMixin {
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final HeadlessWebviewManager _webview;

  GetMangaOnAsuraScanUseCase({
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

    final isValid = [
      result.author != null,
      result.description != null,
      result.tags != null,
    ].every((e) => e);

    if (isValid) return Success(result);

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final content = document.querySelector(
      [
        'div',
        'float-left',
        'relative',
        'z-0',
      ].join('.'),
    );

    final description =
        content?.querySelector('span.font-medium.text-sm')?.text.trim();

    final metas = content
        ?.querySelector(
          [
            'div.grid',
            'grid-cols-1',
            'gap-5',
            'mt-8',
          ].join('.'),
        )
        ?.children
        .map(
      (e) {
        final first = e.querySelector('h3.font-medium.text-sm');
        return MapEntry(
          first?.text.trim(),
          first?.nextElementSibling?.text.trim(),
        );
      },
    );

    final metadata = Map.fromEntries(metas ?? <MapEntry<String?, String>>[]);

    final author = metadata['Author'];

    final genres = content
        ?.querySelector('div.space-y-1.pt-4')
        ?.querySelector('div.flex.flex-row.flex-wrap.gap-3')
        ?.children
        .map((e) => e.text.trim());

    return Success(
      await sync(
        mangaTagServiceFirebase: _mangaTagServiceFirebase,
        mangaServiceFirebase: _mangaServiceFirebase,
        manga: result.copyWith(
          source: MangaSourceEnum.asurascan,
          author: author,
          description: description,
          tags: genres?.map((e) => MangaTag(name: e)).toList(),
        ),
      ),
    );
  }
}
