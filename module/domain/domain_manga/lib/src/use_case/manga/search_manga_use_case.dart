import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import 'search_manga_on_asura_scan_use_case.dart';
import 'search_manga_on_manga_clash_use_case.dart';
import 'search_manga_on_mangadex_use_case.dart';

class SearchMangaUseCase {
  final SearchMangaOnMangaDexUseCase _searchMangaOnMangaDexUseCase;
  final SearchMangaOnMangaClashUseCaseUseCase
      _searchMangaOnMangaClashUseCaseUseCase;
  final SearchMangaOnAsuraScanUseCase _searchMangaOnAsuraScanUseCase;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;
  final MangaServiceFirebase _mangaServiceFirebase;

  const SearchMangaUseCase({
    required SearchMangaOnMangaDexUseCase searchMangaOnMangaDexUseCase,
    required SearchMangaOnMangaClashUseCaseUseCase
        searchMangaOnMangaClashUseCaseUseCase,
    required SearchMangaOnAsuraScanUseCase searchMangaOnAsuraScanUseCase,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
  })  : _searchMangaOnMangaDexUseCase = searchMangaOnMangaDexUseCase,
        _searchMangaOnMangaClashUseCaseUseCase =
            searchMangaOnMangaClashUseCaseUseCase,
        _searchMangaOnAsuraScanUseCase = searchMangaOnAsuraScanUseCase,
        _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<Result<Pagination<Manga>>> execute({
    required MangaSourceEnum? source,
    required SearchMangaParameter parameter,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final result = await switch (source) {
      MangaSourceEnum.mangadex => _searchMangaOnMangaDexUseCase.execute(
          parameter: parameter,
        ),
      MangaSourceEnum.asurascan => _searchMangaOnAsuraScanUseCase.execute(
          parameter: parameter,
        ),
      MangaSourceEnum.mangaclash =>
        _searchMangaOnMangaClashUseCaseUseCase.execute(
          parameter: parameter,
        ),
    };

    if (result is Success<Pagination<Manga>>) {
      final mangas = result.data.data;

      final tags = await Future.wait([
        ...?mangas?.expand((e) => e.tagsName).toSet().map(
              (e) => _mangaTagServiceFirebase.sync(
                value: MangaTag(name: e),
              ),
            ),
      ]);

      return Success(
        result.data.copyWith(
          data: await Future.wait(
            [
              ...?mangas?.map(
                (e) => _mangaServiceFirebase.sync(
                  value: e.copyWith(
                    tags: [
                      ...tags.where(
                        (tag) => e.tagsName.contains(tag.name),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return result;
  }
}
