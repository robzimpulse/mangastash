import 'package:safe_bloc/safe_bloc.dart';

import 'setting_screen_state.dart';

class SettingScreenCubit extends Cubit<SettingScreenState> {

  SettingScreenCubit({
    SettingScreenState initialState = const SettingScreenState(),
  })  : super(initialState);

}
