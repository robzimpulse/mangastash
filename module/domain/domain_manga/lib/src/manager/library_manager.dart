import 'dart:async';

import 'package:collection/collection.dart';
import 'package:core_auth/core_auth.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {
  final _stateSubject = BehaviorSubject<List<String>>.seeded([]);
  final MangaServiceFirebase _mangaServiceFirebase;

  LibraryManager({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
    required MangaServiceFirebase mangaServiceFirebase,
    required ListenAuthUseCase listenAuthUseCase,
  }) : _mangaServiceFirebase = mangaServiceFirebase {
    _stateSubject.addStream(
      SwitchLatestStream(
        listenAuthUseCase.authStateStream.map((authState) {
          final userId = authState?.user?.uid;
          if (userId == null) return Stream.value(<String>[]);
          return mangaLibraryServiceFirebase.stream(userId: userId);
        }),
      ),
    );
  }

  @override
  ValueStream<List<String>> get libraryStateStream => _stateSubject.stream;

  @override
  Future<List<Manga>> get libraryState {
    final ids = _stateSubject.valueOrNull ?? [];
    final futures = ids.map((e) => _mangaServiceFirebase.get(id: e));
    return Future.wait(futures).then(
      (e) => e.whereNotNull().map((e) => Manga.fromFirebaseService(e)).toList(),
    );
  }
}
