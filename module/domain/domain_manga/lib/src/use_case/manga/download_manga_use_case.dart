import 'package:entity_manga/entity_manga.dart';

abstract class DownloadMangaUseCase {
  void downloadManga({
    required String mangaId,
    required MangaSourceEnum source,
  });
}
