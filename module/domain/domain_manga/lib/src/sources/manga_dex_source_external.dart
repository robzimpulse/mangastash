// The built-in MangaDex source. It is native: use cases branch on [builtIn]
// and talk to manga_dex_api, so every scraping hook throws
// UnimplementedError by design.
//
// Usage: obtain it from `SourceRegistry.values` / `fromName('Manga Dex')`;
// never call its scraping hooks.
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

class MangaDexSourceExternal extends SourceExternal {
  @override
  String get baseUrl => 'https://www.mangadex.org';

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  String get name => 'Manga Dex';

  @override
  bool get builtIn => true;

  @override
  Future<String> searchUrl({required SearchMangaParameter parameter}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResultScrapped> search({
    required String url,
    String? searchTerm,
    bool useCache = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MangaScrapped> manga({required String url, bool useCache = true}) {
    throw UnimplementedError();
  }

  @override
  Future<String> chaptersUrl({required String webUrl}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ChapterScrapped>> chapters({
    required String url,
    bool useCache = true,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> images({required String url, bool useCache = true}) {
    throw UnimplementedError();
  }

  @override
  Future<String> tagsUrl() {
    throw UnimplementedError();
  }

  @override
  Future<List<TagScrapped>> tags({required String url, bool useCache = true}) {
    throw UnimplementedError();
  }
}
