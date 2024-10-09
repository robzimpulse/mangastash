import 'dart:ui';

import 'package:core_environment/core_environment.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'general_screen_state.dart';

class GeneralScreenCubit extends Cubit<GeneralScreenState> with AutoSubscriptionMixin {
  final UpdateLocaleUseCase _updateLocaleUseCase;

  GeneralScreenCubit({
    GeneralScreenState initialState = const GeneralScreenState(),
    required UpdateLocaleUseCase updateLocaleUseCase,
    required ListenLocaleUseCase listenLocaleUseCase,
  })  : _updateLocaleUseCase = updateLocaleUseCase,
        super(initialState) {
    addSubscription(
      listenLocaleUseCase.localeDataStream.listen(_updateLocaleData),
    );
  }

  void _updateLocaleData(Locale? data) {
    emit(state.copyWith(locale: data));
  }

  void changeLanguage(String language) {
    final locale = state.locale;
    if (locale == null) return;
    _updateLocaleUseCase.updateLocale(
      locale: Locale(
        Language.fromName(language).code,
        locale.countryCode,
      ),
    );
  }
}
