import 'package:entity_manga_external/entity_manga_external.dart';

abstract class PrefetchMangaUseCase {
  void prefetchManga({required String mangaId, required SourceExternal source});
}
