import 'package:core_environment/core_environment.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'appearance_screen_state.dart';

class AppearanceScreenCubit extends Cubit<AppearanceScreenState>
    with AutoSubscriptionMixin {
  final UpdateThemeUseCase _updateThemeUseCase;

  AppearanceScreenCubit({
    AppearanceScreenState initialState = const AppearanceScreenState(),
    required UpdateThemeUseCase updateThemeUseCase,
    required ListenThemeUseCase listenThemeUseCase,
  })  : _updateThemeUseCase = updateThemeUseCase,
        super(initialState) {
    addSubscription(
      listenThemeUseCase.themeDataStream.listen(_updateThemeData),
    );
  }

  void _updateThemeData(ThemeData data) {
    emit(state.copyWith(isDarkMode: data.brightness == Brightness.dark));
  }

  void changeDarkMode(bool value) {
    _updateThemeUseCase.updateTheme(
      theme: value ? ThemeData.dark() : ThemeData.light(),
    );
  }
}
