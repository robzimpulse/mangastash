import 'package:flutter/cupertino.dart';

import '../enum/route_action_enum.dart';

abstract class UpdateCurrentRouteSettingUseCase {
  void update({required RouteActionEnum action, RouteSettings? setting});
}