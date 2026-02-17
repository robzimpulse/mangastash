import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';

class ListenDownloadedChapterUseCase {
  final ChapterDao _chapterDao;

  ListenDownloadedChapterUseCase({required ChapterDao chapterDao})
    : _chapterDao = chapterDao;

  Stream<List<Chapter>> execute({required mangaId}) {
    return _chapterDao
        .listenDownloadedChapterId(mangaId: mangaId)
        .map((e) => e.map(Chapter.fromDrift).toList());
  }
}
