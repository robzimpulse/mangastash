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
  final _stateSubject = BehaviorSubject<List<MangaSource>>.seeded([]);

  MangaSourceManager({
    required MangaSourceServiceFirebase mangaSourceServiceFirebase,
  }) {
    _stateSubject.addStream(mangaSourceServiceFirebase.stream());
  }

  @override
  List<MangaSource>? get mangaSourceState => mangaSourceStateStream.valueOrNull;

  @override
  ValueStream<List<MangaSource>> get mangaSourceStateStream =>
      _stateSubject.stream;

  @override
  MangaSource? get(MangaSourceEnum source) =>
      mangaSourceState?.firstWhereOrNull((e) => e.name == source);
}
