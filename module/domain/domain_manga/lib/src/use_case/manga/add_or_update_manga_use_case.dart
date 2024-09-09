import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

class AddOrUpdateMangaUseCase {
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaTagServiceFirebase _mangaTagServiceFirebase;

  AddOrUpdateMangaUseCase({
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaTagServiceFirebase mangaTagServiceFirebase,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
        _mangaTagServiceFirebase = mangaTagServiceFirebase;

  Future<void> execute({required List<Manga> data}) async {
    await Future.wait(data.map((e) => _updateManga(manga: e)));
  }

  Future<void> _updateTag({required MangaTag? tag}) async {
    if (tag == null) return;
    await _mangaTagServiceFirebase.update(tag);
  }

  Future<void> _updateManga({required Manga? manga}) async {
    if (manga == null) return;
    final promises = manga.tags?.map((e) => _updateTag(tag: e)) ?? [];
    await Future.wait([...promises, _mangaServiceFirebase.update(manga)]);
  }
}
