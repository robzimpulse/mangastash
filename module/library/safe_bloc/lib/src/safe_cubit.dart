import 'package:flutter_bloc/flutter_bloc.dart' as bloc;

class Cubit<State> extends bloc.Cubit<State> {
  Cubit(super.initialState);

  @override
  void emit(state) {
    if (!isClosed) super.emit(state);
  }
}
