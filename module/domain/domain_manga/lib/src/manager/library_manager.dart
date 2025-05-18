import 'package:core_auth/core_auth.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {
  final _stateSubject = BehaviorSubject<List<Manga>>.seeded([]);

  LibraryManager({
    required LibraryDao libraryDao,
    required ListenAuthUseCase listenAuthUseCase,
  }) {
    _stateSubject.addStream(
      libraryDao.stream.map(
        (values) => [...values.map((e) => Manga.fromDrift(e.$1, tags: e.$2))],
      ),
    );
  }

  @override
  ValueStream<List<Manga>> get libraryStateStream => _stateSubject.stream;

  @override
  List<Manga> get libraryState => libraryStateStream.valueOrNull ?? [];
}
