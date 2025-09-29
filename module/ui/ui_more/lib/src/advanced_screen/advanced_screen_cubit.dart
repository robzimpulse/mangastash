import 'package:core_network/core_network.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'advanced_screen_state.dart';

class AdvancedScreenCubit extends Cubit<AdvancedScreenState> {

  AdvancedScreenCubit({
    AdvancedScreenState initialState = const AdvancedScreenState(),
  })  : super(initialState);

  void init() async {
    final manager = CookieManager.instance();
    final cookies = await manager.getAllCookies();
    emit(state.copyWith(cookies: cookies.map((e) => e.toJson()).toList()));
  }

}