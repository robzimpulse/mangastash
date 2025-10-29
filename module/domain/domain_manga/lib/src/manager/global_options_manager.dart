import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/src/model/manga/search_manga_parameter.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/parameter/listen_search_parameter_use_case.dart';
import '../use_case/parameter/update_search_parameter_use_case.dart';
import '../use_case/source/listen_sources_use_case.dart';
import '../use_case/source/update_sources_use_case.dart';

class GlobalOptionsManager
    implements
        ListenSearchParameterUseCase,
        UpdateSearchParameterUseCase,
        ListenSourcesUseCase,
        UpdateSourcesUseCase {
  final BehaviorSubject<SearchMangaParameter> _searchMangaParameter;
  final BehaviorSubject<List<SourceEnum>> _sources;

  final SharedPreferencesAsync _storage;

  static const String _mangaParameterKey = 'manga_parameter';
  static const String _sourcesKey = 'sources';

  static Future<GlobalOptionsManager> create({
    required SharedPreferencesAsync storage,
  }) async {
    final sources = await storage.getStringList(_sourcesKey);
    final parameter = await storage.getString(_mangaParameterKey);
    return GlobalOptionsManager._(
      storage: storage,
      initialParameter: parameter
          .let(SearchMangaParameter.fromJsonString)
          .or(const SearchMangaParameter()),
      initialSources: sources
          .let((e) => [...e.map((e) => SourceEnum.fromValue(name: e)).nonNulls])
          .or([]),
    );
  }

  GlobalOptionsManager._({
    required SharedPreferencesAsync storage,
    required SearchMangaParameter initialParameter,
    required List<SourceEnum> initialSources,
  }) : _storage = storage,
       _sources = BehaviorSubject.seeded(initialSources),
       _searchMangaParameter = BehaviorSubject.seeded(initialParameter);

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
}
