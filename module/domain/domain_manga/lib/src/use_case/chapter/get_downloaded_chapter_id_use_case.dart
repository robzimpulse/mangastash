import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

class GetDownloadedChapterIdUseCase {
  final ChapterDao _chapterDao;

  GetDownloadedChapterIdUseCase({required ChapterDao chapterDao})
    : _chapterDao = chapterDao;

  Future<List<Chapter>> execute({required String mangaId}) async {
    final result = await _chapterDao.getDownloadedChapterId(mangaId: mangaId);
    return result.map(Chapter.fromDrift).toList();
  }
}
