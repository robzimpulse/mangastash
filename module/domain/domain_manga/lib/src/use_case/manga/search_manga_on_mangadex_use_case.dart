import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchMangaOnMangaDexUseCase {
  final MangaService _mangaService;

  const SearchMangaOnMangaDexUseCase({
    required MangaService mangaService,
  }) : _mangaService = mangaService;

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
      );

      return Success(
        Pagination<Manga>(
          data: result.data
              ?.map(
                (e) => Manga.from(data: e).copyWith(
                  source: MangaSourceEnum.mangadex,
                ),
              )
              .toList(),
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
