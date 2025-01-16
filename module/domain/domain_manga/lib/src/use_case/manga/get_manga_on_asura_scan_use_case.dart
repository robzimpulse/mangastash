import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../../manager/headless_webview_manager.dart';

class GetMangaOnAsuraScanUseCase {
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

    final List<MangaTag> tags = genres == null
        ? []
        : await _mangaTagServiceFirebase.sync(
            values: List.of(genres.map((e) => MangaTag(name: e))),
          );

    return Success(
      result.author == author && result.description == description
          ? result
          : await _mangaServiceFirebase.update(
              key: mangaId,
              update: (old) async => old.copyWith(
                author: author,
                description: description,
                tags: tags
              ),
              ifAbsent: () async => result.copyWith(
                author: author,
                description: description,
                tags: tags,
              ),
            ),
    );
  }
}
