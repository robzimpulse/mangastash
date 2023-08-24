import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'browse_source_state.dart';

class BrowseSourceCubit extends Cubit<BrowseSourceState> {
  BrowseSourceCubit({
    BrowseSourceState initialState = const BrowseSourceState(
      sources: MangaSource.values,
    ),
  }) : super(initialState);
}
