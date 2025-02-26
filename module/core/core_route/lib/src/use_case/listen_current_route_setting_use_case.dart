import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../enum/route_action_enum.dart';

abstract class ListenCurrentRouteSettingUseCase {
  ValueStream<(RouteActionEnum, RouteSettings?)> get currentRouteSettings;
}
