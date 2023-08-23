import 'dart:ui';

import 'package:safe_bloc/safe_bloc.dart';

import 'locale_picker_bottom_sheet_state.dart';

class LocalePickerBottomSheetCubit extends Cubit<LocalePickerBottomSheetState> {
  LocalePickerBottomSheetCubit({
    LocalePickerBottomSheetState initialState =
        const LocalePickerBottomSheetState(),
  }) : super(initialState);

  void update(Locale? locale) {
    emit(state.copyWith(locale: locale));
  }
}
