import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class GetMangaUseCase {
  final MangaRepository _mangaRepository;
  final AuthorRepository _authorRepository;
  final CoverRepository _coverRepository;
  final ChapterRepository _chapterRepository;

  const GetMangaUseCase({
    required MangaRepository mangaRepository,
    required AuthorRepository authorRepository,
    required CoverRepository coverRepository,
    required ChapterRepository chapterRepository,
  })  : _mangaRepository = mangaRepository,
        _authorRepository = authorRepository,
        _coverRepository = coverRepository,
        _chapterRepository = chapterRepository;

  Future<Result<MangaDeprecated>> execute(
    String id, {
    List<Include>? includes,
  }) async {
    try {
      final result = await _mangaRepository.detail(id: id, includes: includes);
      final data = result.data;
      if (data == null) throw Exception('Manga not found');
      return Success(
        MangaDeprecated.from(
          data,
          coverUrl: await _coverArtUrl(data),
          author: await _authors(data),
        ),
      );
    } on Exception catch (e) {
      return Error(e);
    }
  }

  Future<String> _coverArtUrl(MangaData data) async {
    final cover = data.relationships?.firstWhereOrNull(
      (e) => e.type == Include.coverArt.rawValue,
    );
    final mangaId = data.id;
    final coverId = cover?.id;
    if (coverId == null || mangaId == null) return '';
    final response = await _coverRepository.detail(coverId);
    final filename = response.data?.attributes?.fileName;
    if (filename == null) return '';
    return _coverRepository.coverUrl(mangaId, filename);
  }

  Future<List<String>> _authors(MangaData data) async {
    final authors = data.relationships?.where(
      (e) => e.type == Include.author.rawValue,
    );
    if (authors == null) return [];
    final promises = authors.map((e) => _authorRepository.detail(e.id ?? ''));
    final results = await Future.wait(promises);
    return results.map((e) => e.data?.attributes?.name).whereNotNull().toList();
  }
}
