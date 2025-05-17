import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../manager/headless_webview_manager.dart';
import '../../mixin/sync_mangas_mixin.dart';

class GetMangaOnAsuraScanUseCase with SyncMangasMixin {
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaDao _mangaDao;
  final HeadlessWebviewManager _webview;
  final LogBox _logBox;

  GetMangaOnAsuraScanUseCase({
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
    final result = await _mangaDao.getManga(mangaId);
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final tags = await _mangaDao.getTags(mangaId);

    final isValid = [
      result.author != null,
      result.description != null,
      tags.isNotEmpty,
    ].every((e) => e);

    if (isValid) return Success(Manga.fromDrift(result, tags: tags));

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

    final process = sync(
      logBox: _logBox,
      mangaDao: _mangaDao,
      mangaTagServiceFirebase: _mangaTagServiceFirebase,
      mangaServiceFirebase: _mangaServiceFirebase,
      values: [
        Manga.fromDrift(result).copyWith(
          source: MangaSourceEnum.asurascan,
          author: author,
          description: description,
          tags: genres?.map((e) => MangaTag(name: e)).toList(),
        ),
      ],
    );

    final data = (await process).firstOrNull;

    if (data == null) {
      return Error(Exception('Error Syncing Manga'));
    }

    return Success(data);
  }
}
