// LibraryManager streams the library table and filters it to manga whose
// source is in the enabled-sources set (streamed by ListenSourcesUseCase), so
// disabled sources stay hidden app-wide. Constructor requires the use case;
// pass the concrete ListenSourcesUseCase (e.g. GlobalOptionsManager) in prod.
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/listen_manga_from_library_use_case.dart';
import '../use_case/source/listen_sources_use_case.dart';

class LibraryManager implements ListenMangaFromLibraryUseCase {
  final LibraryDao _libraryDao;
  final ListenSourcesUseCase _listenSourcesUseCase;

  LibraryManager({
    required LibraryDao libraryDao,
    required ListenSourcesUseCase listenSourcesUseCase,
  }) : _libraryDao = libraryDao,
       _listenSourcesUseCase = listenSourcesUseCase;

  Stream<List<Manga>> get _stateSubject {
    return Rx.combineLatest2<List<MangaModel>, List<SourceExternal>, List<Manga>>(
      _libraryDao.stream,
      _listenSourcesUseCase.sourceStateStream,
      (models, sources) {
        // The enabled set is keyed by SourceExternal.name; a rename of a
        // source's name string would silently hide its rows (pre-existing
        // coupling, not refactored here).
        final enabled = {...sources.map((e) => e.name)};
        return [
          for (final model in models)
            if (model.manga?.source case final source? when enabled.contains(source))
              Manga.fromDatabase(model)!,
        ];
      },
    ).shareReplay(maxSize: 1);
  }

  @override
  Stream<List<Manga>> get libraryStateStream => _stateSubject;

  @override
  Stream<Set<String>> get libraryMangaIds {
    return _stateSubject
        .map((data) => {...data.map((e) => e.id).nonNulls})
        .shareReplay(maxSize: 1);
  }
}
