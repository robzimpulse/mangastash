import 'package:entity_manga/entity_manga.dart';

abstract class PrefetchMangaUseCase {
  void prefetchManga({required String mangaId, required SourceEnum source});
}
