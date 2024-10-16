import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';

import '../library/check_manga_exists_on_library_use_case.dart';
import '../library/get_manga_from_library_use_case.dart';
import 'get_manga_on_mangadex_use_case.dart';

class GetMangaUseCase {
  final GetMangaOnMangaDexUseCase _getMangaOnMangaDexUseCase;
  final CheckMangaExistsOnLibraryUseCase _checkMangaExistsOnLibraryUseCase;

  GetMangaUseCase({
    required GetMangaOnMangaDexUseCase getMangaOnMangaDexUseCase,
    required CheckMangaExistsOnLibraryUseCase checkMangaExistsOnLibraryUseCase,
  })  : _getMangaOnMangaDexUseCase = getMangaOnMangaDexUseCase,
        _checkMangaExistsOnLibraryUseCase = checkMangaExistsOnLibraryUseCase;

  Future<Result<Manga>> execute({
    required MangaSourceEnum? source,
    required String mangaId,
    String? userId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<Manga> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _getMangaOnMangaDexUseCase.execute(mangaId: mangaId);
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    if (result is Success<Manga> && userId != null) {
      final isExists = await _checkMangaExistsOnLibraryUseCase.execute(
        manga: result.data,
        userId: userId,
      );

      if (isExists is Success<bool>) {
        return Success(result.data.copyWith(isOnLibrary: isExists.data));
      }
    }

    return result;
  }
}
