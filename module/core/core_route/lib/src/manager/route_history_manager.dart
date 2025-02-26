import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../enum/route_action_enum.dart';
import '../use_case/listen_current_route_setting_use_case.dart';
import '../use_case/update_current_route_setting_use_case.dart';

class RouteHistoryManager
    implements
        ListenCurrentRouteSettingUseCase,
        UpdateCurrentRouteSettingUseCase {
  final BehaviorSubject<(RouteActionEnum, RouteSettings?)> _history =
      BehaviorSubject();

  @override
  ValueStream<(RouteActionEnum, RouteSettings?)> get currentRouteSettings =>
      _history.stream;

  @override
  void update({required RouteActionEnum action, RouteSettings? setting}) {
    _history.add((action, setting));
  }
}
