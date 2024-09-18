import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetMangaOnMangaDexUseCase {
  final MangaService _mangaService;
  final AuthorService _authorService;
  final CoverArtService _coverArtService;

  GetMangaOnMangaDexUseCase({
    required MangaService mangaService,
    required AuthorService authorService,
    required CoverArtService coverArtService,
  })  : _mangaService = mangaService,
        _authorService = authorService,
        _coverArtService = coverArtService;

  Future<Result<Manga>> execute({required String mangaId}) async {
    try {
      final result = await _mangaService.detail(id: mangaId);
      final manga = result.data;
      if (manga == null) throw Exception('Manga not found');
      return Success(
        Manga(
          id: manga.id,
          title: manga.attributes?.title?.en,
          description: manga.attributes?.description?.en,
          coverUrl: await _coverArtUrl(manga),
          status: result.data?.attributes?.status,
          tags: result.data?.attributes?.tags
              ?.map((e) => MangaTag(name: e.attributes?.name?.en, id: e.id))
              .toList(),
          author: (await _authors(manga)).join(' | '),
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<List<String>> _authors(MangaData data) async {
    final authors = data.relationships?.where(
      (e) => e.type == Include.author.rawValue,
    );
    if (authors == null) return [];
    final promises = authors.map((e) => _authorService.detail(id: e.id ?? ''));
    final results = await Future.wait(promises);
    return results.map((e) => e.data?.attributes?.name).whereNotNull().toList();
  }

  Future<String> _coverArtUrl(MangaData data) async {
    final cover = data.relationships?.firstWhereOrNull(
      (e) => e.type == Include.coverArt.rawValue,
    );
    final mangaId = data.id;
    final coverId = cover?.id;
    if (coverId == null || mangaId == null) return '';
    final response = await _coverArtService.detail(id: coverId);
    final filename = response.data?.attributes?.fileName;
    if (filename == null) return '';
    return 'https://uploads.mangadex.org/covers/$mangaId/$filename';
  }
}
