import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetMangaOnMangaDexUseCase {
  final MangaService _mangaService;

  GetMangaOnMangaDexUseCase({
    required MangaService mangaService,
  })  : _mangaService = mangaService;

  Future<Result<Manga>> execute({required String mangaId}) async {
    try {
      final result = await _mangaService.detail(
        id: mangaId,
        includes: [Include.author.rawValue, Include.coverArt.rawValue],
      );
      final manga = result.data;
      if (manga == null) throw Exception('Manga not found');

      List<String> authors = [];
      String? coverArtUrl;

      final relationships = manga.relationships ?? [];
      for (final relationship in relationships) {
        if (relationship is Relationship<AuthorDataAttributes>) {
          final name = relationship.attributes?.name;
          if (name != null) authors.add(name);
        }
        if (relationship is Relationship<CoverArtDataAttributes>) {
          final filename = relationship.attributes?.fileName;
          coverArtUrl = 'https://uploads.mangadex.org/covers/$mangaId/$filename';
        }
      }

      return Success(
        Manga(
          id: manga.id,
          title: manga.attributes?.title?.en,
          description: manga.attributes?.description?.en,
          coverUrl: coverArtUrl,
          status: result.data?.attributes?.status,
          tags: result.data?.attributes?.tags
              ?.map((e) => MangaTag(name: e.attributes?.name?.en, id: e.id))
              .toList(),
          author: authors.join(' | '),
          webUrl: 'https://mangadex.org/title/${manga.id}',
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }
}
