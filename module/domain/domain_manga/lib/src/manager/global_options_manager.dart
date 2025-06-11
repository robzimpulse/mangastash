import 'dart:async';
import 'dart:ui';

import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/src/model/manga/search_manga_parameter.dart';
import 'package:rxdart/rxdart.dart';

import '../extension/language_code_converter.dart';
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
  final _searchMangaParameter = BehaviorSubject<SearchMangaParameter>.seeded(
    const SearchMangaParameter(),
  );
  final _sources = BehaviorSubject<List<Source>>.seeded(const []);

  late final StreamSubscription _streamSubscription;

  GlobalOptionsManager({required ListenLocaleUseCase listenLocaleUseCase}) {
    _streamSubscription =
        listenLocaleUseCase.localeDataStream.distinct().listen(_updateLocale);
  }

  Future<void> dispose() => _streamSubscription.cancel();

  void _updateLocale(Locale? locale) {
    final codes = Language.fromCode(locale?.languageCode).languageCodes;
    _searchMangaParameter.valueOrNull?.let(
      (state) => _searchMangaParameter.add(
        state.copyWith(
          availableTranslatedLanguage: {
            ...?state.availableTranslatedLanguage,
            ...codes,
          }.toList(),
        ),
      ),
    );
  }

  @override
  ValueStream<SearchMangaParameter> get searchParameterState =>
      _searchMangaParameter.stream;

  @override
  void updateSearchParameter({required SearchMangaParameter parameter}) {
    _searchMangaParameter.add(parameter);
  }

  @override
  ValueStream<List<Source>> get sourceStateStream => _sources.stream;

  @override
  void updateSources(List<Source> sources) {
    _sources.add(sources);
  }
}
