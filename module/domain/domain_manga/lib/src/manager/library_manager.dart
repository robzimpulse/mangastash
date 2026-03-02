import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager implements ListenMangaFromLibraryUseCase {
  final LibraryDao _libraryDao;

  LibraryManager({required LibraryDao libraryDao}) : _libraryDao = libraryDao;

  Stream<List<Manga>> get _stateSubject {
    return _libraryDao.stream
        .map((values) => [...values.map(Manga.fromDatabase).nonNulls])
        .shareReplay(maxSize: 1);
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
