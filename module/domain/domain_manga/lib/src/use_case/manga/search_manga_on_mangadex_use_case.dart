import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class SearchMangaOnMangaDexUseCase {
  final MangaService _mangaService;
  final AuthorService _authorService;
  final CoverArtService _coverArtService;

  const SearchMangaOnMangaDexUseCase({
    required MangaService mangaService,
    required AuthorService authorService,
    required CoverArtService coverArtService,
  })  : _mangaService = mangaService,
        _authorService = authorService,
        _coverArtService = coverArtService;

  Future<Result<Pagination<Manga>>> execute({
    required SearchMangaParameter parameter,
  }) async {
    try {
      log('${parameter.toJson()}', name: '$SearchMangaOnMangaDexUseCase');
      final offset = int.tryParse(parameter.offset ?? '') ?? 0;

      final result = await _mangaService.search(
        title: parameter.title,
        limit: parameter.limit,
        offset: offset + (parameter.limit ?? 0),
      );

      final promises = result.data?.map(_mapManga).toList() ?? [];
      final mangas = await Future.wait(promises);

      return Success(
        Pagination<Manga>(
          data: mangas,
          offset: (result.offset ?? 0).toString(),
          limit: result.limit ?? 0,
          total: result.total ?? 0,
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
    return Manga(
      id: data.id,
      coverUrl: await _coverArtUrl(data),
      title: data.attributes?.title?.en,
      status: data.attributes?.status,
      description: data.attributes?.description?.en,
      author: (await _authors(data)).join(' | '),
      tags: tags?.toList(),
    );
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

  Future<List<String>> _authors(MangaData data) async {
    final authors = data.relationships?.where(
      (e) => e.type == Include.author.rawValue,
    );
    if (authors == null) return [];
    final promises = authors.map((e) => _authorService.detail(id: e.id ?? ''));
    final results = await Future.wait(promises);
    return results.map((e) => e.data?.attributes?.name).whereNotNull().toList();
  }
}
