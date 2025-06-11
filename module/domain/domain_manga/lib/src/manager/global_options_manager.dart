import 'dart:async';

import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/src/model/manga/search_manga_parameter.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/manga/listen_search_parameter_use_case.dart';
import '../use_case/manga/update_search_parameter_use_case.dart';
import '../use_case/source/listen_sources_use_case.dart';
import '../use_case/source/update_sources_use_case.dart';

class GlobalOptionsManager
    implements
        ListenSearchParameterUseCase,
        UpdateSearchParameterUseCase,
        ListenSourcesUseCase,
        UpdateSourcesUseCase {
  final BehaviorSubject<SearchMangaParameter> _searchMangaParameter;
  final BehaviorSubject<List<Source>> _sources;

  final Storage _storage;

  static const String _mangaParameterKey = 'manga_parameter';
  static const String _sourcesKey = 'sources';

  GlobalOptionsManager({required Storage storage})
      : _storage = storage,
        _sources = BehaviorSubject.seeded(
          storage
              .getStringList(_sourcesKey)
              .let((e) => [...e.map(Source.fromJsonString).nonNulls])
              .or([]),
        ),
        _searchMangaParameter = BehaviorSubject.seeded(
          storage
              .getString(_mangaParameterKey)
              .let(SearchMangaParameter.fromJsonString)
              .or(const SearchMangaParameter()),
        );

  Future<void> dispose() async {}

  @override
  ValueStream<SearchMangaParameter> get searchParameterState =>
      _searchMangaParameter.stream;

  @override
  void updateSearchParameter({required SearchMangaParameter parameter}) {
    _searchMangaParameter.add(parameter);
    _storage.setString(_mangaParameterKey, parameter.toJsonString());
  }

  @override
  ValueStream<List<Source>> get sourceStateStream => _sources.stream;

  @override
  void updateSources({required List<Source> sources}) {
    _sources.add(sources);
    _storage.setStringList(
      _sourcesKey,
      [...sources.map((e) => e.toJsonString())],
    );
  }
}
