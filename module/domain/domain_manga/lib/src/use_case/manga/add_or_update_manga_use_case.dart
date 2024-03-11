import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class AddOrUpdateMangaUseCase {
  final MangaService _mangaService;
  final MangaTagService _mangaTagService;

  AddOrUpdateMangaUseCase({
    required MangaService mangaService,
    required MangaTagService mangaTagService,
  })  : _mangaService = mangaService,
        _mangaTagService = mangaTagService;

  Future<void> execute({required List<Manga> data}) async {
    for (final manga in data) {
      for (final tag in manga.tags ?? []) {
        final id = tag.id;
        if (id == null) continue;
        final isExists = await _mangaTagService.exists(id);
        if (isExists) {
          await _mangaTagService.update(tag);
        } else {
          await _mangaTagService.add(tag);
        }
      }

      final id = manga.id;
      if (id == null) return;
      final isExists = await _mangaService.exists(id);
      if (isExists) {
        await _mangaService.update(manga);
      } else {
        await _mangaService.add(manga);
      }
    }
  }
}
