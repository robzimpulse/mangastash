import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

mixin AutoSubscriptionMixin<S> on BlocBase<S> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  Future<void> close() async {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.close();
  }

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
}
