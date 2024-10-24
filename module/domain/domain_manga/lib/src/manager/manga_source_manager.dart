import 'dart:async';

import 'package:collection/collection.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/src/manga_source.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/manga_source/get_manga_source_use_case.dart';
import '../use_case/manga_source/get_manga_sources_use_case.dart';
import '../use_case/manga_source/listen_manga_source_use_case.dart';

class MangaSourceManager
    implements
        ListenMangaSourceUseCase,
        GetMangaSourcesUseCase,
        GetMangaSourceUseCase {
  static final _finalizer = Finalizer<StreamSubscription>(
    (event) => event.cancel(),
  );

  final _stateSubject = BehaviorSubject<List<MangaSource>>.seeded([]);

  MangaSourceManager({
    required MangaSourceServiceFirebase mangaSourceServiceFirebase,
  }) {
    _finalizer.attach(
      this,
      mangaSourceServiceFirebase.stream().listen(_updateState),
      detach: this,
    );
  }

  @override
  List<MangaSource>? get mangaSourceState => mangaSourceStateStream.valueOrNull;

  @override
  ValueStream<List<MangaSource>> get mangaSourceStateStream =>
      _stateSubject.stream;

  @override
  MangaSource? get(String? id) =>
      mangaSourceState?.firstWhereOrNull((e) => e.id == id);

  void _updateState(List<MangaSource> sources) {
    _stateSubject.add(sources);
  }
}
