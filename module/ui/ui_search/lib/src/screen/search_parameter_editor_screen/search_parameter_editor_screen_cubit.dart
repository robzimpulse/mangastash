import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_parameter_editor_screen_cubit_state.dart';

class SearchParameterEditorScreenCubit extends Cubit<SearchParameterEditorScreenCubitState> with AutoSubscriptionMixin {

  final ListenListTagUseCase listenListTagUseCase;

  SearchParameterEditorScreenCubit({
    required this.listenListTagUseCase,
    SearchParameterEditorScreenCubitState initState = const SearchParameterEditorScreenCubitState(
      parameter: SearchMangaParameter(),
      tags: [],
    ),
  }) : super(initState) {
    addSubscription(listenListTagUseCase.listTagsStream.listen(_onReceiveTag));
  }

  void _onReceiveTag(List<Tag> tags) {
    emit(state.copyWith(tags: tags));
  }

}