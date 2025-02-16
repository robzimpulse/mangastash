import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchMangaOnMangaDexUseCase {
  final MangaService _mangaService;
  final LogBox _log;

  const SearchMangaOnMangaDexUseCase({
    required MangaService mangaService,
    required LogBox log,
  })  : _mangaService = mangaService,
        _log = log;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    try {
      _log.log(
        '${parameter.toJson()}',
        name: runtimeType.toString(),
      );

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
          data: result.data?.map((e) => Manga.from(data: e)).toList(),
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
