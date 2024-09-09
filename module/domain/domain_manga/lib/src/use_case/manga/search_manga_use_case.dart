import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required MangaSourceEnum? source,
    required SearchMangaParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<Pagination<Manga>> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _searchMangaOnMangaDexUseCase.execute(
          parameter: parameter,
        );
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    if (result is Success<Pagination<Manga>>) {
      final mangas = result.data.data ?? [];
      await _syncManga(
        data: mangas.map((e) => e.copyWith(source: source)).toList(),
      );
    }

    return result;
  }

  Future<void> _syncManga({required List<Manga> data}) async {
    await Future.wait(data.map((e) => _updateManga(manga: e)));
  }

  Future<void> _updateTag({required MangaTag? tag}) async {
    if (tag == null) return;
    await _mangaTagServiceFirebase.update(tag);
  }

  Future<void> _updateManga({required Manga? manga}) async {
    if (manga == null) return;
    final promises = manga.tags?.map((e) => _updateTag(tag: e)) ?? [];
    await Future.wait([...promises, _mangaServiceFirebase.update(manga)]);
  }

}
