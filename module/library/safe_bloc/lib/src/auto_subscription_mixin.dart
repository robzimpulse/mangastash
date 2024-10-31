import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

mixin AutoSubscriptionMixin<S> on BlocBase<S> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  Future<void> close() async {
    await Future.wait(_subscriptions.map((e) => e.cancel()));
    _subscriptions.clear();
    await super.close();
  }

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
}
