import 'package:safe_bloc/safe_bloc.dart';

import 'browse_screen_state.dart';

class BrowseScreenCubit extends Cubit<BrowseScreenState> {
  BrowseScreenCubit({
    BrowseScreenState initialState = const BrowseScreenState(),
  }) : super(initialState);
}
