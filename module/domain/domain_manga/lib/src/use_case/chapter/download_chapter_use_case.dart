import 'package:entity_manga/entity_manga.dart';

abstract class DownloadChapterUseCase {
  Future<void> downloadChapter({required DownloadChapterKey key});
}
