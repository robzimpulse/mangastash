import 'package:safe_bloc/safe_bloc.dart';

import 'manga_misc_state.dart';

class MangaMiscCubit extends Cubit<MangaMiscState> with AutoSubscriptionMixin {
  MangaMiscCubit({
    MangaMiscState initialState = const MangaMiscState(),
  }) : super(initialState);
}
