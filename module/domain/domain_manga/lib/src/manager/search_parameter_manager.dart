import 'package:manga_dex_api/src/model/manga/search_manga_parameter.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/manga/listen_search_parameter_use_case.dart';
import '../use_case/manga/update_search_parameter_use_case.dart';

class SearchParameterManager
    implements ListenSearchParameterUseCase, UpdateSearchParameterUseCase {
  final _stateSubject = BehaviorSubject<SearchMangaParameter>.seeded(
    const SearchMangaParameter(),
  );

  @override
  ValueStream<SearchMangaParameter> get searchParameterState =>
      _stateSubject.stream;

  @override
  void updateSearchParameter({required SearchMangaParameter parameter}) {
    _stateSubject.add(parameter);
  }
}
