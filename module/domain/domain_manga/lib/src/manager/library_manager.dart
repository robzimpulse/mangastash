import 'dart:async';

import 'package:core_auth/core_auth.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/library/get_manga_from_library_use_case.dart';
import '../use_case/library/listen_manga_from_library_use_case.dart';

class LibraryManager
    implements GetMangaFromLibraryUseCase, ListenMangaFromLibraryUseCase {
  late final SwitchLatestStream<List<Manga>> _switchLatestStream;

  static final _finalizer = Finalizer<StreamSubscription>(
    (event) => event.cancel(),
  );

  final _stateSubject = BehaviorSubject<List<Manga>>.seeded([]);

  LibraryManager({
    required MangaLibraryServiceFirebase mangaLibraryServiceFirebase,
    required ListenAuthUseCase listenAuthUseCase,
  }) {
    _switchLatestStream = SwitchLatestStream(
      listenAuthUseCase.authStateStream.map((authState) {
        final userId = authState?.user?.uid;
        if (userId == null) return Stream.value(<Manga>[]);
        return mangaLibraryServiceFirebase.stream(userId);
      }),
    );
    _finalizer.attach(
      this,
      _switchLatestStream.listen(_updateState),
      detach: this,
    );
  }

  @override
  ValueStream<List<Manga>> get libraryStateStream => _stateSubject.stream;

  @override
  List<Manga> get libraryState => _stateSubject.valueOrNull ?? [];

  void _updateState(List<Manga> library) {
    _stateSubject.add(library);
  }
}
