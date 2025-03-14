import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/manga_tag/get_manga_tag_use_case.dart';
import '../use_case/manga_tag/get_manga_tags_use_case.dart';
import '../use_case/manga_tag/listen_manga_tag_use_case.dart';

class MangaTagManager
    implements ListenMangaTagUseCase, GetMangaTagUseCase, GetMangaTagsUseCase {
  final _stateSubject = BehaviorSubject<Map<String, MangaTag>>.seeded({});

  MangaTagManager({
    required MangaTagServiceFirebase mangaTagServiceFirebase,
  }) {
    _stateSubject.addStream(mangaTagServiceFirebase.stream);
  }

  @override
  MangaTag? get(String id) => mangaTagState[id];

  @override
  Map<String, MangaTag> get mangaTagState => _stateSubject.valueOrNull ?? {};

  @override
  ValueStream<Map<String, MangaTag>> get mangaTagStateStream =>
      _stateSubject.stream;
}
