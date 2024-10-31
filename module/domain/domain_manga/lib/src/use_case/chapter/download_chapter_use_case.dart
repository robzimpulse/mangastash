import 'package:entity_manga/entity_manga.dart';

abstract class DownloadChapterUseCase {
  void downloadChapter({
    required DownloadChapter key,
  });
}
