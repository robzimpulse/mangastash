import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:rxdart/rxdart.dart';

abstract class ListenSearchParameterUseCase {
  ValueStream<SearchMangaParameter> get searchParameterState;
}
