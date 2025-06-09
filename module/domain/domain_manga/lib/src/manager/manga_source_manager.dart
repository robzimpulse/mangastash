import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/manga_source/get_manga_source_use_case.dart';
import '../use_case/manga_source/get_manga_sources_use_case.dart';
import '../use_case/manga_source/listen_manga_source_use_case.dart';

class MangaSourceManager
    implements
        ListenMangaSourceUseCase,
        GetMangaSourcesUseCase,
        GetMangaSourceUseCase {
  final _stateSubject = BehaviorSubject<Map<String, Source>>.seeded({});

  MangaSourceManager({
    required MangaSourceServiceFirebase mangaSourceServiceFirebase,
  }) {
    _stateSubject.addStream(
      mangaSourceServiceFirebase.stream.map(
        (event) => event.map(
          (key, value) => MapEntry(
            key,
            Source.fromFirebaseService(value),
          ),
        ),
      ),
    );
  }

  @override
  Map<String, Source> get mangaSourceState =>
      mangaSourceStateStream.valueOrNull ?? {};

  @override
  ValueStream<Map<String, Source>> get mangaSourceStateStream =>
      _stateSubject.stream;

  @override
  Source? get(String name) =>
      mangaSourceState.values.firstWhereOrNull((e) => e.name == name);
}
