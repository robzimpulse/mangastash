import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {
  final _stateSubject = BehaviorSubject<List<String>>.seeded([]);
  final _libraryStateSubject = BehaviorSubject<List<Manga>>.seeded([]);

  LibraryManager({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required ListenAuthUseCase listenAuthUseCase,
  }) {
    _stateSubject.addStream(
      SwitchLatestStream(
        listenAuthUseCase.authStateStream.map((authState) {
          final userId = authState?.user?.uid;
          if (userId == null) return Stream.value(<String>[]);
          return mangaLibraryServiceFirebase.stream(userId: userId);
        }),
      ),
    );
    _libraryStateSubject.addStream(
      _stateSubject
          .map(
            (ids) => CombineLatestStream(
              ids.map((id) => mangaServiceFirebase.stream(id: id)),
              (e) => e.whereNotNull().toList(),
            ).share(),
          )
          .asyncExpand((e) => e),
    );
  }

  @override
  ValueStream<List<String>> get libraryIdsStateStream => _stateSubject.stream;

  @override
  ValueStream<List<Manga>> get libraryStateStream =>
      _libraryStateSubject.stream;

  @override
  List<Manga> get libraryState => _libraryStateSubject.valueOrNull ?? [];
}
