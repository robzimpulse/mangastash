import 'dart:async';
import 'dart:ui';

import 'package:core_environment/core_environment.dart';
import 'package:manga_dex_api/src/model/manga/search_manga_parameter.dart';
import 'package:rxdart/rxdart.dart';

import '../extension/language_code_converter.dart';
import '../use_case/manga/listen_search_parameter_use_case.dart';
import '../use_case/manga/update_search_parameter_use_case.dart';

class SearchParameterManager
    implements ListenSearchParameterUseCase, UpdateSearchParameterUseCase {
  final _stateSubject = BehaviorSubject<SearchMangaParameter>.seeded(
    const SearchMangaParameter(),
  );

  late final StreamSubscription _streamSubscription;

  SearchParameterManager({required ListenLocaleUseCase listenLocaleUseCase}) {
    _streamSubscription =
        listenLocaleUseCase.localeDataStream.distinct().listen(_updateLocale);
  }

  Future<void> dispose() => _streamSubscription.cancel();

  void _updateLocale(Locale? locale) {
    final codes = Language.fromCode(locale?.languageCode).languageCodes;
    _stateSubject.valueOrNull?.let(
      (state) => _stateSubject.add(
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
      _stateSubject.stream;

  @override
  void updateSearchParameter({required SearchMangaParameter parameter}) {
    _stateSubject.add(parameter);
  }
}
