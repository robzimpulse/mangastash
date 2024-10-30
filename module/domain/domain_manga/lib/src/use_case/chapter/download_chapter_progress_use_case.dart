import 'package:entity_manga/entity_manga.dart';

abstract class DownloadChapterProgressUseCase {
  double downloadChapterProgress({
    MangaSourceEnum? source,
    String? mangaId,
    String? chapterId,
  });
}