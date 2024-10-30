import 'package:entity_manga/entity_manga.dart';

abstract class DownloadChapterUseCase {
  void downloadChapter({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });
}
