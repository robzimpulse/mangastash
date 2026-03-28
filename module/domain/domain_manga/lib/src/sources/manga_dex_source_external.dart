import 'package:entity_manga_external/entity_manga_external.dart';

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
  // TODO: implement getChapterImageUseCase
  GetChapterSourceExternalUseCase get getChapterImageUseCase =>
      throw UnimplementedError();

  @override
  // TODO: implement getMangaUseCase
  GetMangaSourceExternalUseCase get getMangaUseCase =>
      throw UnimplementedError();

  @override
  // TODO: implement searchChapterUseCase
  SearchChapterSourceExternalUseCase get searchChapterUseCase =>
      throw UnimplementedError();

  @override
  // TODO: implement searchMangaUseCase
  SearchMangaSourceExternalUseCase get searchMangaUseCase =>
      throw UnimplementedError();
}
