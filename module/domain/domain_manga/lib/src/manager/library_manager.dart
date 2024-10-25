import 'dart:async';

import 'package:core_auth/core_auth.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {

  final _stateSubject = BehaviorSubject<List<Manga>>.seeded([]);

  LibraryManager({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
    required ListenAuthUseCase listenAuthUseCase,
  }) {
    _stateSubject.addStream(
      SwitchLatestStream(
        listenAuthUseCase.authStateStream.map(
          (authState) {
            final userId = authState?.user?.uid;
            if (userId == null) return Stream.value(<Manga>[]);
            return mangaLibraryServiceFirebase.stream(userId);
          },
        ),
      ),
    );
  }

  @override
  ValueStream<List<Manga>> get libraryStateStream => _stateSubject.stream;

  @override
  List<Manga> get libraryState => _stateSubject.valueOrNull ?? [];
}
