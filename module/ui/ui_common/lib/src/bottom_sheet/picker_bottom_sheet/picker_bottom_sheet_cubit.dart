import 'package:safe_bloc/safe_bloc.dart';

import 'picker_bottom_sheet_state.dart';

class PickerBottomSheetCubit extends Cubit<PickerBottomSheetState> {
  PickerBottomSheetCubit({
    required PickerBottomSheetState initialState,
  }) : super(initialState);

  void search(String keyword) {
    emit(state.copyWith(keyword: keyword));
  }

}
