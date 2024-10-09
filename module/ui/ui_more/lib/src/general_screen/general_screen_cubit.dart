import 'package:safe_bloc/safe_bloc.dart';

import 'general_screen_state.dart';

class GeneralScreenCubit extends Cubit<GeneralScreenState> {

  GeneralScreenCubit({
    GeneralScreenState initialState = const GeneralScreenState(),
  })  : super(initialState);

}