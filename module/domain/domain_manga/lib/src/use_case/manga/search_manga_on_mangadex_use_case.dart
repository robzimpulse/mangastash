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
        includes: [Include.author.rawValue, Include.coverArt.rawValue],
      );

      final promises = result.data?.map(_mapManga).toList() ?? [];
      final mangas = await Future.wait(promises);

      return Success(
        Pagination<Manga>(
          data: mangas,
          offset: (result.offset ?? 0).toString(),
          limit: result.limit?.toInt() ?? 0,
          total: result.total?.toInt() ?? 0,
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<Manga> _mapManga(MangaData data) async {
    final tags = data.attributes?.tags?.map(
      (e) => MangaTag(name: e.attributes?.name?.en, id: e.id),
    );

    List<String> authors = [];
    String? coverArtUrl;

    final relationships = data.relationships ?? [];
    for (final relationship in relationships) {
      if (relationship is Relationship<AuthorDataAttributes>) {
        final name = relationship.attributes?.name;
        if (name != null) authors.add(name);
      }
      if (relationship is Relationship<CoverArtDataAttributes>) {
        final filename = relationship.attributes?.fileName;
        coverArtUrl = [
          'https://uploads.mangadex.org',
          'covers',
          data.id,
          filename,
        ].join('/');
      }
    }

    return Manga(
      id: data.id,
      coverUrl: coverArtUrl,
      title: data.attributes?.title?.en,
      status: data.attributes?.status,
      description: data.attributes?.description?.en,
      author: authors.join(' | '),
      tags: tags?.toList(),
    );
  }
}
