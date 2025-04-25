import 'package:collection/collection.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/manga_source/get_manga_source_use_case.dart';
import '../use_case/manga_source/get_manga_sources_use_case.dart';
import '../use_case/manga_source/listen_manga_source_use_case.dart';

class MangaSourceManager
    implements
        ListenMangaSourceUseCase,
        GetMangaSourcesUseCase,
        GetMangaSourceUseCase {
  final _stateSubject = BehaviorSubject<Map<String, MangaSource>>.seeded({});

  MangaSourceManager({
    required MangaSourceServiceFirebase mangaSourceServiceFirebase,
  }) {
    _stateSubject.addStream(
      mangaSourceServiceFirebase.stream.map(
        (event) => event.map(
          (key, value) => MapEntry(
            key,
            MangaSource.fromFirebaseService(value),
          ),
        ),
      ),
    );
  }

  @override
  Map<String, MangaSource> get mangaSourceState =>
      mangaSourceStateStream.valueOrNull ?? {};

  @override
  ValueStream<Map<String, MangaSource>> get mangaSourceStateStream =>
      _stateSubject.stream;

  @override
  MangaSource? get(MangaSourceEnum source) =>
      mangaSourceState.values.firstWhereOrNull((e) => e.name == source);
}
