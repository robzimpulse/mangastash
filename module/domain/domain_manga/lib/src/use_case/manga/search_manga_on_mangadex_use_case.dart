import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import '../../mixin/sync_manga_mixin.dart';

class SearchMangaOnMangaDexUseCase with SyncMangaMixin {
  final MangaService _mangaService;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;

  const SearchMangaOnMangaDexUseCase({
    required MangaService mangaService,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
  })  : _mangaService = mangaService,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    try {
      final result = await _mangaService.search(
        title: parameter.title,
        limit: parameter.limit?.toInt(),
        offset: int.tryParse(parameter.offset ?? '') ?? 0,
        includes: [
          Include.author.rawValue,
          Include.coverArt.rawValue,
        ],
        orders: parameter.orders?.map(
          (key, value) => MapEntry(key.rawValue, value.rawValue),
        ),
        status: parameter.status?.map((e) => e.rawValue).toList(),
      );

      final mangas = result.data?.map(
        (e) => Manga.from(data: e).copyWith(
          source: MangaSourceEnum.mangadex,
        ),
      );

      return Success(
        Pagination(
          data: await sync(
            mangaTagServiceFirebase: _mangaTagServiceFirebase,
            mangaServiceFirebase: _mangaServiceFirebase,
            mangas: mangas?.toList() ?? [],
          ),
          offset: (result.offset ?? 0).toString(),
          limit: result.limit?.toInt() ?? 0,
          total: result.total?.toInt() ?? 0,
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
