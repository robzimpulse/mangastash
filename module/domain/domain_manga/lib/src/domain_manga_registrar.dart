import 'dart:developer';

import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:service_locator/service_locator.dart';

import 'manager_deprecated/tags_manager.dart';
import 'use_case/manga/add_or_update_manga_use_case.dart';
import 'use_case/manga/search_manga_on_mangadex_use_case.dart';
import 'use_case/manga_source/add_manga_source_use_case.dart';
import 'use_case/manga_source/get_list_manga_sources_use_case.dart';
import 'use_case/manga_source/get_manga_source_use_case.dart';
import 'use_case/manga_source/search_manga_source_use_case.dart';
import 'use_case/manga_source/update_manga_source_use_case.dart';
import 'use_case/manga_tags/get_list_tags_use_case.dart';
import 'use_case_deprecated/get_all_chapter_use_case.dart';
import 'use_case_deprecated/get_author_use_case.dart';
import 'use_case_deprecated/get_chapter_image_use_case.dart';
import 'use_case_deprecated/get_chapter_use_case.dart';
import 'use_case_deprecated/get_cover_art_use_case.dart';
import 'use_case_deprecated/get_manga_use_case.dart';
import 'use_case_deprecated/list_tag_use_case.dart';
import 'use_case_deprecated/listen_list_tag_use_case.dart';
import 'use_case_deprecated/search_chapter_use_case.dart';
import 'use_case_deprecated/search_manga_use_case.dart';

class DomainMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());

    await _deprecated(locator);

    locator.registerFactory(
      () => AddMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => UpdateMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => GetListMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => GetMangaSourceUseCase(service: locator()),
    );
    locator.registerFactory(
      () => SearchMangaSourcesUseCase(service: locator()),
    );
    locator.registerFactory(
      () => GetListTagsUseCase(service: locator()),
    );
    locator.registerFactory(
      () => SearchMangaOnMangaDexUseCase(
        mangaService: locator(),
        authorService: locator(),
        coverArtService: locator(),
      ),
    );
    locator.registerFactory(
      () => AddOrUpdateMangaUseCase(
        mangaServiceFirebase: locator(),
        mangaTagServiceFirebase: locator(),
      ),
    );
    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }

  Future<void> _deprecated(ServiceLocator locator) async {
    // manga dex services
    locator.registerFactory(() => MangaService(locator()));
    locator.registerFactory(() => ChapterService(locator()));
    locator.registerFactory(() => AtHomeService(locator()));
    locator.registerFactory(() => AuthorService(locator()));
    locator.registerFactory(() => CoverArtService(locator()));

    // manga dex repositories
    locator.registerFactory(() => AtHomeRepository(service: locator()));
    locator.registerFactory(() => MangaRepository(service: locator()));
    locator.registerFactory(() => ChapterRepository(service: locator()));
    locator.registerFactory(() => AuthorRepository(service: locator()));
    locator.registerFactory(() => CoverRepository(service: locator()));

    locator.registerFactory(() => GetAuthorUseCase(repository: locator()));
    locator.registerFactory(() => GetCoverArtUseCase(repository: locator()));
    locator.registerFactory(
      () => ListTagUseCaseDeprecated(repository: locator()),
    );
    locator.registerFactory(() => SearchChapterUseCase(repository: locator()));

    locator.registerFactory(
      () => GetChapterImageUseCase(
        repository: locator(),
      ),
    );

    locator.registerFactory(
      () => SearchMangaUseCaseDeprecated(
        mangaRepository: locator(),
        authorRepository: locator(),
        coverRepository: locator(),
      ),
    );

    locator.registerFactory(
      () => GetAllChapterUseCase(
        chapterRepository: locator(),
      ),
    );

    locator.registerFactory(
      () => GetMangaUseCase(
        mangaRepository: locator(),
        authorRepository: locator(),
        coverRepository: locator(),
        chapterRepository: locator(),
      ),
    );

    locator.registerFactory(
      () => GetChapterUseCase(
        atHomeRepository: locator(),
        chapterRepository: locator(),
      ),
    );

    locator.registerSingleton(TagsManagerDeprecated(listTagUseCase: locator()));
    locator.alias<ListenListTagUseCaseDeprecated, TagsManagerDeprecated>();
  }
}
