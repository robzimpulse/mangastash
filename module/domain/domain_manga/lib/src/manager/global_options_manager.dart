import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/parameter/listen_search_parameter_use_case.dart';
import '../use_case/parameter/update_search_parameter_use_case.dart';
import '../use_case/prefetch/listen_prefetch_chapter_config.dart';
import '../use_case/source/listen_sources_use_case.dart';
import '../use_case/source/update_sources_use_case.dart';

class GlobalOptionsManager
    implements
        ListenSearchParameterUseCase,
        UpdateSearchParameterUseCase,
        ListenSourcesUseCase,
        UpdateSourcesUseCase,
        ListenPrefetchChapterConfig {
  final BehaviorSubject<SearchMangaParameter> _searchMangaParameter;
  final BehaviorSubject<List<SourceEnum>> _sources;
  final BehaviorSubject<int> _numOfPrefetchedPrevChapter;
  final BehaviorSubject<int> _numOfPrefetchedNextChapter;

  final SharedPreferencesAsync _storage;

  static const String _mangaParameterKey = 'manga_parameter';
  static const String _sourcesKey = 'sources';
  static const String _numOfPrefetchedPrevChapterKey = 'num_of_prev_chapter';
  static const String _numOfPrefetchedNextChapterKey = 'num_of_next_chapter';

  static Future<GlobalOptionsManager> create({
    required SharedPreferencesAsync storage,
  }) async {
    final sources = await storage.getStringList(_sourcesKey);
    final parameter = await storage.getString(_mangaParameterKey);
    final numOfPrefetchedPrevChapter = await storage.getInt(
      _numOfPrefetchedPrevChapterKey,
    );
    final numOfPrefetchedNextChapter = await storage.getInt(
      _numOfPrefetchedNextChapterKey,
    );

    return GlobalOptionsManager._(
      storage: storage,
      initialParameter: parameter
          .let(SearchMangaParameter.fromJsonString)
          .or(
            const SearchMangaParameter(
              orders: {SearchOrders.createdAt: OrderDirections.descending},
              availableTranslatedLanguage: [LanguageCodes.english],
            ),
          ),
      initialSources: sources
          .let((e) => [...e.map((e) => SourceEnum.fromValue(name: e)).nonNulls])
          .or(SourceEnum.values),
      numOfPrefetchedPrevChapter: numOfPrefetchedPrevChapter ?? 0,
      numOfPrefetchedNextChapter: numOfPrefetchedNextChapter ?? 0,
    );
  }

  GlobalOptionsManager._({
    required SharedPreferencesAsync storage,
    required SearchMangaParameter initialParameter,
    required List<SourceEnum> initialSources,
    int numOfPrefetchedPrevChapter = 0,
    int numOfPrefetchedNextChapter = 0,
  }) : _storage = storage,
       _sources = BehaviorSubject.seeded(initialSources),
       _searchMangaParameter = BehaviorSubject.seeded(initialParameter),
       _numOfPrefetchedNextChapter = BehaviorSubject.seeded(
         numOfPrefetchedNextChapter,
       ),
       _numOfPrefetchedPrevChapter = BehaviorSubject.seeded(
         numOfPrefetchedPrevChapter,
       );

  @override
  ValueStream<SearchMangaParameter> get searchParameterState =>
      _searchMangaParameter.stream;

  @override
  Future<void> updateSearchParameter({
    required SearchMangaParameter parameter,
  }) async {
    await _storage.setString(_mangaParameterKey, parameter.toJsonString());
    _searchMangaParameter.add(parameter);
  }

  @override
  ValueStream<List<SourceEnum>> get sourceStateStream => _sources.stream;

  @override
  Future<void> updateSources({required List<SourceEnum> sources}) async {
    await _storage.setStringList(_sourcesKey, [...sources.map((e) => e.name)]);
    _sources.add(sources);
  }

  @override
  ValueStream<int> get numOfPrefetchedNextChapter {
    return _numOfPrefetchedNextChapter.stream;
  }

  @override
  ValueStream<int> get numOfPrefetchedPrevChapter {
    return _numOfPrefetchedPrevChapter.stream;
  }

  @override
  void updateNumOfPrefetchedNextChapter({required int value}) async {
    await _storage.setInt(_numOfPrefetchedNextChapterKey, value);
    _numOfPrefetchedNextChapter.add(value);
  }

  @override
  void updateNumOfPrefetchedPrevChapter({required int value}) async {
    await _storage.setInt(_numOfPrefetchedPrevChapterKey, value);
    _numOfPrefetchedPrevChapter.add(value);
  }
}
