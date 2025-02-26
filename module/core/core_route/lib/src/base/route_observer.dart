import 'package:flutter/widgets.dart';

import '../enum/route_action_enum.dart';
import '../use_case/update_current_route_setting_use_case.dart';

class BaseRouteObserver extends NavigatorObserver {
  final UpdateCurrentRouteSettingUseCase _updateCurrentRouteSettingUseCase;

  BaseRouteObserver({
    required UpdateCurrentRouteSettingUseCase updateCurrentRouteSettingUseCase,
  })  : _updateCurrentRouteSettingUseCase = updateCurrentRouteSettingUseCase,
        super();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentRouteSettingUseCase.update(
      action: RouteActionEnum.push,
      setting: route.settings,
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _updateCurrentRouteSettingUseCase.update(
      action: RouteActionEnum.pop,
      setting: route.settings,
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _updateCurrentRouteSettingUseCase.update(
      action: RouteActionEnum.remove,
      setting: route.settings,
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateCurrentRouteSettingUseCase.update(
      action: RouteActionEnum.replace,
      setting: newRoute?.settings,
    );
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    _updateCurrentRouteSettingUseCase.update(
      action: RouteActionEnum.startUserGesture,
      setting: route.settings,
    );
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    _updateCurrentRouteSettingUseCase.update(
      action: RouteActionEnum.stopUserGesture,
    );
  }
}
