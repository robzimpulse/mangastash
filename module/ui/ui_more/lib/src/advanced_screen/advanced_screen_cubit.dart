import 'package:safe_bloc/safe_bloc.dart';

import 'advanced_screen_state.dart';

class AdvancedScreenCubit extends Cubit<AdvancedScreenState> {

  AdvancedScreenCubit({
    AdvancedScreenState initialState = const AdvancedScreenState(),
  })  : super(initialState);

}