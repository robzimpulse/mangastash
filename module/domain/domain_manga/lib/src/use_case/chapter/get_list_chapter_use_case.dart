import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import 'get_list_chapter_on_manga_dex_use_case.dart';

class GetListChapterUseCase {
  final GetListChapterOnMangaDexUseCase _getListChapterOnMangaDexUseCase;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;

  const GetListChapterUseCase({
    required GetListChapterOnMangaDexUseCase getListChapterOnMangaDexUseCase,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
  })  : _getListChapterOnMangaDexUseCase = getListChapterOnMangaDexUseCase,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase;

  Future<Result<List<MangaChapter>>> execute({
    required MangaSourceEnum? source,
    required String? mangaId,
  }) async {
    if (source == null) return Error(Exception('Empty Source'));

    final Result<List<MangaChapter>> result;

    switch (source) {
      case MangaSourceEnum.mangadex:
        result = await _getListChapterOnMangaDexUseCase.execute(
          mangaId: mangaId,
        );
        break;
      case MangaSourceEnum.asurascan:
        result = Error(Exception('Unimplemented for ${source.name}'));
        break;
    }

    if (result is Success<List<MangaChapter>>) {
      _sync(data: result.data);
    }

    return result;
  }

  Future<void> _sync({required List<MangaChapter> data}) async {
    await Future.wait(data.map((e) => _mangaChapterServiceFirebase.update(e)));
  }
}
