import 'dart:async';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {
  final _stateSubject = BehaviorSubject<List<Manga>>.seeded([]);

  late final StreamSubscription subscription;

  LibraryManager({required LibraryDao libraryDao}) {
    subscription = libraryDao.stream
        .map((values) => [...values.map(Manga.fromDatabase).nonNulls])
        .listen(_stateSubject.add);
  }

  Future<void> dispose() async {
    await subscription.cancel();
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
