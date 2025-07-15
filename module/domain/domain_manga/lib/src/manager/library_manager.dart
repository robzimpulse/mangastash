import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {
  final _stateSubject = BehaviorSubject<List<Manga>>.seeded([]);

  LibraryManager({required LibraryDao libraryDao}) {
    _stateSubject.addStream(
      libraryDao.stream.map(
        (values) => [...values.map(Manga.fromDatabase).nonNulls],
      ),
    );
  }

  @override
  Stream<List<Manga>> get libraryStateStream => _stateSubject.stream;

  @override
  Stream<Set<String>> get libraryMangaIds {
    return _stateSubject.map((data) => {...data.map((e) => e.id).nonNulls});
  }

  @override
  List<Manga> get libraryState => _stateSubject.valueOrNull ?? [];
}
